# AGENTS.md — AI Contributor Reference for RISC_V_pipelined_private

> This file is the canonical onboarding prompt for **all AI agents** (Claude,
> Copilot, Cursor, Gemini, ChatGPT, open-source harnesses) working in this repo.
> Read this file **before** reading any RTL. Keep it up to date when architecture,
> memory map, or flow changes.

## 1. What this project is

- **Title:** Pipelining an RV32I RISC-V Core — A Study of Hazard Resolution,
  Performance, and FPGA Timing Tradeoffs.
- **Author:** Tristan Niewenhuis (independent study, Fall 2026).
- **ISA:** RV32I only. **No M, no F, no atomics (yet).** Every `mul` becomes a
  libgcc `__mulsi3` shift-add loop with a data-dependent branch per bit. This
  inflates branch density vs. any published RV32IM number — **always disclose
  this confound**, never let a reviewer discover it.
- **Platform:** Digilent Nexys A7, Xilinx Artix-7 `xc7a100tcsg324-1`.
- **Language / tools:** VHDL-2008, Vivado **2026.1**,
  `riscv64-unknown-elf-gcc` at `C:/AMDDesignTools/2026.1/gnu/riscv/nt/bin`,
  Sigasi (`project.sigasi` maps `RISC_V.srcs` -> `work`).
- **Status:** Work in progress. Current RTL is **stall-only**. Partial/full
  forwarding are planned variants measured on a common axis.

## 2. Research question (do not lose sight of this)

> Does reducing pipeline stalls through forwarding always improve real-world
> performance?

Build and measure **three hazard-handling configurations of the same 5-stage
core**:

1. **Stall-only (current):** detect RAW hazard, freeze pipe, let value land in
   register file before dependent instruction reads it.
2. **Partial forwarding:** forward from **EX/MEM only**, stall for the rest.
3. **Full forwarding:** forward from **EX/MEM and MEM/WB**, plus the
   **load-use stall that forwarding cannot eliminate**.

Each configuration is measured for **CPI, Fmax, LUT, FF** over a **fixed
benchmark set**. One configuration measured once is a milestone; three
configurations on a common axis is a result.

### The honest metric

```text
Performance = IPC x Fmax   (equivalently wall-clock time per benchmark)
```

- Forwarding **will** improve CPI — that is what it is for.
- Forwarding **will** insert muxes into the EX-stage input path, where the
  critical path already lives, and **will** cost Fmax.
- Full forwarding may **lose to partial forwarding** in wall-clock terms.
  If so you have not failed — **report it**.
- Reference lesson (Miyazaki et al., RVCoreP, same Artix-7 part, Nexys4 DDR):
  no-predictor `205 MHz / IPC 0.626 = 1.000` vs bimodal+BTB
  `140 MHz / IPC 0.801 = 0.873`. IPC +28%, Fmax -32%, net slower. The predictor
  only paid after they pipelined the prediction path. Same physics applies to
  forwarding muxes.

Timing currency on Artix-7 (from RVCoreP — reason with it, re-measure):

- Block-RAM access: ~2.54 ns. Each extra LUT level: ~0.12 ns.
- Their critical path ~6.1 ns -> cap near ~165 MHz.
- ama-riscv (5-stage RV32IM, same `xc7a100tcsg324-1`) hit a hard 2^8 PHT
  ceiling from **timing closure, not accuracy**. Expect the same class of wall.

## 3. Canonical sources — where AI may look and edit

### Context budget (owner directive — obey strictly)

- **Allowed by default:** anything under `RISC_V.srcs/` (RTL + sim + `.xci`
  sources + `RISC_V.sim/sim_1/behav/xsim/RISC_V.tcl`).
- `RISC_V.gen/` only if usable **without bloating context**. Prefer `.xci` +
  `.srcs` over generated products.
- **Do not** load or churn: `RISC_V.runs/`, `RISC_V.cache/`, `RISC_V.hw/`,
  `RISC_V.ip_user_files/` (except `mem_init_files/*.coe` when debugging
  images), `*.jou`, `*.log`, `*.str`, `*.pb`, `*.wdb`, `*.bit`, `*.bin`,
  `*.ltx`, `*.wcfg` (inspect a named waveform only if asked).
- Respect `.gitignore`: only `RISC_V.sim/sim_1/behav/xsim/RISC_V.tcl` is
  allow-listed under `.sim`; everything else generated stays untracked.
- **NEVER run git commit / push / stage / gh writes.** Owner is sole holder of
  git commands. Read-only `status/diff/log` is allowed; do not stage or commit.

### Top-level variants

| Entity | File | Role |
|---|---|---|
| `RISC_V_TCM` | `RISC_V.srcs/sources_1/new/RISC_V_TCM.vhdl` | **CANONICAL.** Core + internal ITCM/DTCM + AXI4-Lite master. Edit here first. |
| `RISC_V` | `RISC_V.srcs/sources_1/new/RISC_V.vhdl` | Legacy native-BRAM top (`Datapath` + `Load_Store` to `RISC_V_block` BRAM IP). Sync only if asked. |
| `RISC_V_AXI` | `RISC_V.srcs/sources_1/new/RISC_V_AXI.vhdl` | AXI variant (`Datapath_AXI` + `Fetch_AXI` + `Load_Store_AXI`). External-RAM compatible; large miss penalty. For prefetch study. |

Block-design wrapper + JTAG test platform: `RISC_V.srcs/sources_1/bd/`,
`test_controller.vhdl`, `JTAG_LED_TEST.vhdl` (`axi_led` at `0xDEADBEEF`).

### Pipeline microarchitecture (stall-only baseline)

Classic 5-stage: **IF -> ID -> EX -> MEM -> WB.**

- `datapath.vhdl` (`Datapath`): native-BRAM timing. PC in `generic_counter`,
  `Instruction_Decoder` in IF, regfile `generic_register_file` in ID (x0 = 0,
  **internal same-cycle WB bypass** — not full forwarding), `ALU` + `btu` in
  EX, `Load_Store` sub-word formatting in MEM, writeback mux in WB.
- `datapath_AXI.vhdl` (`Datapath_AXI`): same control, but
  `fetch_addr_valid/fetch_inst_valid` and `ls_addr_valid/ls_done_valid`
  handshake with `Fetch_AXI`/`Load_Store_AXI`. Adds `fetch_hazard`,
  `ls_hazard`.
- Registers `IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB` are clocked processes with
  per-stage `stall` (hold), `nop` (bubble), `clr` (flush). Control words
  narrow along the pipe (`control_word_if_id -> control_word_id_ex ->
  control_word_ex_mem -> control_word_mem_wb`) via converters in
  `RISCV_package.vhdl`. NOP constants `CONTROL_WORD_*_NOP` zero enables;
  `Dsel=0` means no writeback.
- **Hazard logic today (stall-only, no forwarding muxes yet):**
  `id_ex_{a,b}_hazard` (IF/ID Rs == ID/EX.Dsel, nonzero, used, Dlen=1),
  `ex_mem_{a,b}_hazard` (vs EX/MEM.Dsel), `raw_hazard` = OR of four,
  `branch_hazard = branch_take & !branch_correct`. `id_ex_nop <= raw_hazard`
  (+ fetch/branch terms in AXI variant). Stalls chain upstream. Branch
  resolves in **EX**; mispredict flushes IF/ID + ID/EX. When adding
  forwarding, preserve a **1-cycle load-use stall**.
- `USE_BRAM_NEGEDGE` / `USE_NEGEDGE`: when true, BRAM read ports latch on
  **falling edge** so `pc` / MEM-registered address meets BRAM mid-cycle; data
  returns before next rising edge (~2.1 ns clock-to-Q vs 5 ns half-period at
  100 MHz). CPI unchanged. Port-B writes stay rising-edge.

### Module inventory (`RISC_V.srcs/sources_1/new/`)

- `RISCV_package.vhdl` — `sl/slv`, `XLEN=32`, `I_BYTES_ADDR_BITS=16`,
  `D_BYTES_ADDR_BITS=16`, `PRE_FETCH_BURST_SIZE=4`, `I_MEM_BASE=0x00000000 /
  0x10000`, `D_MEM_BASE=0x80000000 / 0xFFE0`, `D_IO_BASE=0xC0000000`,
  control-word records + NOPs + converters, `clog2/decode/vector_and`,
  `DEBUG=TRUE`.
- `Instruction_Decoder.vhdl` — combinational RV32I decode to
  `control_word_if_id` (`Asel/Aused/Bsel/Bused`, `PCAsel/IMMBsel/PCle/isBR`,
  `ALUFunc_CSRtype`, `IMM`, `is_load/is_store`, `BRcond_LStype`,
  `is_CSR/CSR_reg`, `Dsel/Dlen/PCDsel/LoadDsel`). `force_add` forces ADD.
- `ALU.vhdl` — `func[3:0]`; bit0 add/sub; `[3:1]`: 000 add/sub, 001/101 shift,
  010 slt, 011 sltu, 100 xor, 110 or, 111 and. Shifts via `generic_shifter`.
- `btu.vhdl` — branch comparator; `cond[2:1]` selects eq/lt/slt, `cond[0]`
  inverts; `BTU_out <= (pre_out xor cond(0)) and enable`.
- `Load_Store.vhdl` — native path: address-out, sub-word load align +
  sign/zero extend, store splay + `write_strobe` byte/half masks.
- `Load_Store_AXI.vhdl` — AXI master engines (IDLE/SEND_ADDR/ACCEPTING),
  single-beat, error if `RRESP/BRESP(1)=1`. `done_valid <= BVALID or RVALID`.
- `Fetch_AXI.vhdl` — burst prefetch FIFO of `{addr,data}`; miss issues
  `2*PRE_FETCH_BURST_SIZE` beats, half-refill `PRE_FETCH_BURST_SIZE`;
  `data_valid <= addr_hit`; FIFO reset on miss. Pipelined IF stresses it; any
  change here is a legitimate paper result.
- `tightly_coupled_memory.vhdl` — true dual-port BRAM, sync read (1-cycle,
  read-first), byte-lane writes, `ready='1'`, combinational `fault` on
  read-only write (=> `mcause=7`). Generics `SIZE_BYTES` (pow2 >= 8),
  `INIT_FILE` (.hex/.bin/.coe), `READ_ONLY`, `PORT_B_WRITE`, `USE_NEGEDGE`.
  No access-type ops; read-only ports must use generics, not constant `we`.
- `CSR_regs.vhdl` — `mcycle/mcycleh (0xB00/0xB80)` + `cycle/cycleh`,
  `time/timeh` (auto-inc); `minstret/minstreth (0xB02/0xB82)` +
  `instret/instreth` (inc on `exec=1`). ECALL/EBREAK -> **no retire, no
  `instret` inc**.
- `generic_CSR.vhdl`, `status_register.vhdl` — WARL/PASS primitive; `mstatus`
  with MIE/MPIE clear/restore (`mret`), S-mode/VS/FS/XS = 0, MPP=`11`.
- `generic_counter/register/register_file/shifter/FIFO` — PC counter,
  enable-register (`mark_debug`), 31-entry regfile + bypass, barrel shifter,
  FIFO with `empty/full/below_threshold`.
- `RISC_V_TCM.vhdl` internals — ITCM port A = fetch, port B = ITCM loads;
  DTCM port A = loads, port B = stores; stores to ITCM dropped; peripherals
  registered into MEM, `mem_stall := periph_q & !axi_done` holds IF->MEM.
- `io_interconnect.vhdl` — splits DRAM vs MMIO by `D_MEM_SIZE_LOGICAL`.
- `test_controller.vhdl` — AXI4-Lite slave + RISC-V MMIO sink: cycle/instret
  capture, `done` (STATUS bit0), `CPU_resetn`. See section 5.

### Test / sim sources

- `RISC_V.srcs/sim_1/new/RISC_V_tb.vhdl` — block-design TB with
  `axi_write/axi_read` procedures (write `1` to `0xC0000014` to release CPU,
  read `0xC0000004`, write/read `0x80000050` loopback). Pattern for future TBs.
- `RISC_V.srcs/sim_1/new/axi_led*.vhdl` — AXI4-Lite LED smoke test (not CPU).
- `cylon_test/cylon_test.S` — LED-chase + `delay()` loop: switches at
  `0x40010000`, LEDs at `0x40000000`, shift left to 32768 then right to 1.
  Default smoke image for bring-up (not mandatory for every sim).
- `embench-iot-files/` — Harvard build: `Makefile`, `link.ld`,
  `harvard_startup.S` (sp -> `__StackTop`, zero `.bss`, `jal main`, `hang`),
  `boardsupport.c` (`initialise_board/start_trigger/stop_trigger` with
  `rdcycle/rdcycleh` + `0x12345678` marker in `a2`), `make_coe.ps1` /
  `disassemble.ps1` (`.text` -> ROM, `.rodata+.data` -> RAM, bin -> COE hex).
  `build/` is generated.
- `run_tests.py` — JTAG-to-AXI batch harness: loads `iram/dram` binaries via
  bursts (`AXI_BURST_WORDS=256`), toggles reset, polls `DONE` every 50 ms up
  to 60 s, writes `embench_results.csv`. Template `TESTS` still points at
  `C:\PUT\YOUR\PATH\HERE` — fill per run; do not commit real absolute paths
  without asking.

## 4. Memory map (read carefully — two views exist)

### A. RTL package view (`RISCV_package.vhdl`)

- `I_MEM_BASE 0x00000000`, `I_MEM_SIZE 0x10000` (64 KiB).
- `D_MEM_BASE 0x80000000`, `D_MEM_SIZE 0xFFE0` (~64 KiB - 32 B).
- `D_IO_BASE 0xC0000000` — MMIO/test-controller window.
- Board AXI GPIO (per `RISC_V_TCM` header): LEDs `0x40000000`, switches
  `0x40010000`.

### B. Linker / harness view (`link.ld`, `run_tests.py`)

- `link.ld`: `ROM(rx) 0x80000000 len 0x10000` (`.text`), `RAM(rwx) 0x00000000
  len 0xFFE0` (`.rodata/.data/.bss`, stack top = RAM origin + length).
  **Note the swap vs. package names** — ROM links at `0x8000_0000` while the
  package calls `0x0000_0000` I-space. Harness exposes `IRAM_AXI_BASE
  0x00000000`, `DRAM_AXI_BASE 0x00010000`. Do not "fix" one side without
  checking TCM instantiation, `itcm_fetch_addr`, `dtcm_ld_addr`, block-design
  address editor, and COE placement together.
- `test_controller` MMIO (AXI4-Lite from PC + RISC-V store path):
  `0xC0000000 cycle_lo`, `0xC0000004 cycle_hi`, `0xC0000008 instret_lo`,
  `0xC000000C instret_hi`, `0xC0000010 STATUS (bit0=DONE)`,
  `0xC0000014 CPU_RESET (0=assert, 1=release)`. RISC-V reports via `1111`
  -strobe stores to `0xC0000000+N*4`; PC reads back via AXI4-Lite.
  `cycle_hi` resets to `0x12349876` sentinel in sim — not a real count.

When in doubt, trust instantiated generics + address editor over prose, and
flag the discrepancy in your summary.

## 5. Benchmarks and methodology (from PROJECT_BRIEF — normative)

- **Primary: Embench-IoT** (GPL-3.0). Fits 64 KiB prog + 64 KiB RAM -> Nexys A7
  BRAM. Master has 19 benchmarks (FP members of 1.0 excluded -> viable on
  FPU-less RV32I). Port = 3 funcs in `boardsupport.c`
  (`initialise_board/start_trigger/stop_trigger` — snapshots go in triggers).
  Free size score alongside speed = second results table at no extra work.
  Default branch frozen since Aug 2024, no final 2.0 — **use it anyway**.
- **Secondary: CoreMark.** Apache-2.0 code but separate trademark agreement
  bars using the CoreMark name on a modified copy. Sanctioned path: port
  `core_portme.*`, leave rest alone. Run rules: >= 10 s, validation seeds.
  RISC-V port defaults to RV64GC — retargeting to `rv32i/ilp32` is real work.
- **Footnote: Dhrystone.** Report only for comparison to old numbers, and say
  why you distrust it: RVCoreP gshare 0.943 on Dhrystone but 0.801 on
  CoreMark; bimodal-class 0.832 vs 0.760. Short biased repetitive branches ->
  almost no global correlation.
- **TACLeBench:** easiest bare-metal bring-up (`gcc *.c`, no libs, no I/O)
  but **no license declared** — fine for coursework, problem for a paper
  claiming an open artifact.

Expected signal (collect in fall so spring knows):

- Likely to differentiate: `nsichneu`, `statemate`, `slre`, `huffbench`,
  `wikisort`, `sglib-combined`, CoreMark.
- Expect null: `crc32`, `matmult-int`, `aha-mont64`, `tarfind`, `depthconv`,
  `xgboost`, `nettle-aes`, `nettle-sha256`, Dhrystone. **A null on half the
  suite is normal — report as workload evidence, not a defect.**

### Four methodology rules (enforce on any AI results claim)

1. Report **MPKI + mispredict rate + dynamic/static branch counts** per bench
   (plus CPI/cycles). Instrument fetch stalls, not just mispredicts, so spring
   can test fetch x predict interaction.
2. Report **per-benchmark numbers, never only the geometric mean**. The geomean
   hides exactly the effect under study.
3. Compare at **equal storage budget and sweep it**. The crossover point is the
   result; a single-size comparison establishes nothing.
4. Disclose the **RV32I-no-mul** (`__mulsi3`) confound explicitly.

### Counters (Privileged 20260120 Sections 3.1.10-3.1.12, Vol I Ch.7 Zicntr/Zihpm)

- `mcycle/minstret`, `mhpmcounter3-31` + `mhpmevent3-31` for
  branch/mispredict/fetch-stall events, `...h` high halves (RV32 needs them),
  `mcountinhibit` to gate counting so setup does not pollute numbers.
- Borrow riscv-test `stats(code,iter)` macro (`benchmarks/common/util.h`);
  ignore bundled Berkeley smoke scores.

### Baselines on the exact part (cite, mimic table shape)

- **RVCoreP** (Miyazaki/Kanamori/Islam/Kise, IEICE 2020, arXiv:2002.03568):
  5-stage RV32I, `xc7a100tcsg324-1`, full Fmax/LUT/FF/IPC/hit-rate tables.
  **Template for your results table.**
- **ama-riscv:** 5-stage RV32IM, same part, parameterised
  static/bimodal/gshare/gselect/combined.
- **VexRiscv:** README Artix-7 numbers (no paper — cite as repository):
  ~199 MHz / 1840 LUT / 1158 FF static vs ~200 MHz / 1935 LUT / 1216 FF with
  dynamic target prediction.
- Spring trap: Mendes/Figueiredo/Menotti (SSCAD 2024, Portuguese) already
  compared BTFNT/1-bit/2-bit/gselect/gshare on 5-stage RV32I. **Cite it** or
  face a "replication" review. Open gaps: (a) joint LUT/FF/BRAM+Fmax vs
  PHT/BTB curve on Xilinx (knee: PHT LUTRAM->BRAM nearly free in LUTs but
  +~2.54 ns; BTB tag compare eats LUT levels); (b) **prefetch interaction** —
  fetch stall + mispredict **serialise** in-order behind AXI burst prefetch
  (may invert vs Eyerman OOO overlap). **Fall job: leave the pipe able to
  count fetch stalls and fetch x mispredict coincidences.**

## 6. Toolchain, build, and verification (what AI must run)

- **Supported flow:** Vivado 2026.1 + `riscv64-unknown-elf-gcc` + Sigasi VHDL.
  Vivado in `PATH` as `vivado`; else set `VIVADO` in `run_tests.py`. GNU path
  `C:/AMDDesignTools/2026.1/gnu/riscv/nt/bin`.
- **Compile flags (Embench Harvard):**
  `CFLAGS="-O2 -ffunction-sections -fdata-sections -march=rv32i_zicsr_zicntr
  -mabi=ilp32"`, `LDFLAGS` same + `-Wl,--gc-sections -Wl,--no-warn-rwx-segments
  -static -nostartfiles harvard_startup.o -T link.ld`, `gsf=1`. (Upstream
  README shows `rv32imc_zicsr` for CV32E40P — **this core is
  `rv32i_zicsr_zicntr`; do not copy `imc` flags blindly.**)
- **Required checks on any pipeline/CSR/memory-map edit:**
  1. **Sigasi check** (`RISC_V`, `project.sigasi`) — must be clean.
  2. **Vivado sim** (`RISC_V_tb` or the bench image the user names — **not
     always `cylon_test`**; ask or infer). Keep `RISC_V.tcl` allow-listed; do
     not commit other sim products.
- **FPGA benchmark flow (when asked to measure):** `make elf -> dis -> coe`
  in `embench-iot-files/` -> per-bench `*_rom.coe/*_ram.coe` -> program
  BRAM/`mem_init_files` or JTAG-to-AXI load -> `python run_tests.py` (AXI
  bases + `0xC000_0000` region, `DONE_POLL` 50 ms, timeout 60 s) ->
  `embench_results.csv`. `BITSTREAM=None` means FPGA already programmed; set a
  path only when asked to program.
- **Never claim without running:** Fmax (needs synth/impl timing), CPI/IPC
  (needs sim or `mcycle/minstret` on HW), LUT/FF (needs utilization).
  Estimates must be labeled estimates.

## 7. VHDL coding rules for AI edits

- Use `sl`/`slv` from `RISCV_package`, never bare `std_logic(_vector)` in new
  ports unless matching an IP boundary (e.g. AXI). Reuse `clog2`, `decode`,
  control-word records + `*_NOP` + converters.
- **Vivado-2026.1 compatibility (hard):** no access-type ops (null checks,
  `.all` dereference) in synthesis; read-only BRAM ports via `READ_ONLY` /
  `PORT_B_WRITE` generics (not constant `we`); keep `rom_style` for ROMs;
  mirror `tightly_coupled_memory.vhdl` templates when in doubt.
- Clocking/reset: internal `reset` is **active-high** (`reset <= not resetn`
  at tops); `rising_edge(clk)` except explicit `USE_NEGEDGE` port-A paths
  (falling edge, address valid by mid-cycle, writes via port B if full-cycle
  timing needed). Keep `x0=0`, regfile bypass, `fault` combinational.
- Style: `library IEEE; use IEEE.std_logic_1164.all; use
  IEEE.numeric_std.all; use work.RISCV_package.all;` header; `Behavioral`
  architectures; no new latches; one entity per file named after the file.
- Timing discipline: keep EX-input muxing minimal; any new forwarding mux must
  note its critical-path cost. Do not widen the PC/adder->BRAM path when
  `USE_NEGEDGE=true`.

## 8. How to behave on this repo (agent conduct)

1. **Plan first:** restate which top (`RISC_V_TCM` default), which stages /
   files, and which checks you will run — then implement.
2. **Small diffs:** fewest RTL files that achieve the task; do not reformat
   unrelated VHDL or regenerate IP/block-design products.
3. **Verify:** Sigasi + Vivado sim as in section 6; paste failing assertions /
   timing lines verbatim and fix forward. No CPI/Fmax without data.
4. **Report per section 5:** per-benchmark table + storage budget + confounds;
   never geomean-only; flag any memory-map assumption.
5. **Context hygiene:** stay in `RISC_V.srcs/`; peek at `RISC_V.gen/` only when
   necessary and say why; never commit; never invent absolute bench paths.
6. **Docs:** update this `AGENTS.md` and `README.md` TODOs when your change
   invalidates them (new top, new CSR event, new address).

---
*Sources: `README.md`, `Docs/PROJECT_BRIEF.pdf` (4 pp., Aug 2026),
`RISC_V.srcs/sources_1/new/*.vhdl`, `RISC_V.srcs/sim_1/new/*`,
`embench-iot-files/{Makefile,link.ld,harvard_startup.S,boardsupport.c,
make_coe.ps1}`, `run_tests.py`, `cylon_test/cylon_test.S`, `.gitignore`,
`project.sigasi`. Generated 2026-10-08 for future AI prompts.*





