# RV32I pipeline and forwarding test

This is a bare-metal assembly test for a custom, in-order RV32I core. It is built
without libc/startup files; `_start` is the reset entry point. The instructions
exercise common five-stage-pipeline hazards and selected integer/memory behaviors.

## Build

Install a RISC-V GNU bare-metal toolchain (`riscv64-unknown-elf-gcc`, `objdump`,
`readelf`) and Python 3. The `riscv64-unknown-elf-` tool prefix can target RV32
when `-march=rv32i -mabi=ilp32` is specified.

```sh
make clean
make
```

If your installation uses a different prefix, specify it explicitly:

```sh
make CROSS=riscv32-unknown-elf-
# or, for another common installation:
make CROSS=riscv-none-elf-
```

To use the same architecture string as your existing C build:

```sh
make ARCH=rv32i_zicsr_zicntr ABI=ilp32
```

The program itself only emits RV32I instructions; it does not read CSRs or
hardware counters. `make` creates:

- `build/pipeline_test.elf`: linked ELF, entry point `_start` at address `0x0`.
- `build/pipeline_test.lst`: disassembly with numeric registers and base ISA mnemonics.
- `build/pipeline_test.map`: linker map.
- `build/rom.coe`: exactly 16,384 32-bit words covering `0x00000000..0x0000ffff`.
- `build/ram.coe`: 16,384 32-bit words covering the 64-KiB RAM backing store `0x00010000..0x0001ffff`. The linker preserves the supplied 32-byte top gap, so the last eight words are unused/zero.

The included reference COEs were generated from this assembly with Clang/LLD because a RISC-V GNU GCC toolchain was not available in the build environment. Running `make` with your GNU toolchain rebuilds the ELF and regenerates both COEs from that ELF. The ELF-to-COE generator uses ELF section virtual addresses to place initialized
sections. `.bss` and unused locations remain zero. The first COE vector entry
maps to the lowest memory address; each vector item is one 32-bit word with the
four instruction/data bytes assembled in little-endian order. Configure Vivado memories as 32-bit wide and depth 16,384 for both COEs. The data-memory COE has eight extra zero words above the linker-visible RAM range because your linker script reserves the top 32 bytes. To generate an exact `0xFFE0`-byte data image instead, run `make clean && make RAM_IMAGE_BYTES=0xFFE0`; use a physical memory depth that your Vivado IP supports.

## Memory map and waveform checks

The linker script follows the supplied layout:

| Region | Base | Length | COE depth (32-bit words) |
|---|---:|---:|---:|
| Instruction ROM | `0x00000000` | `0x00010000` | 16,384 |
| Data RAM linker region | `0x00010000` | `0x0000FFE0` | 16,376 words; upper 32 bytes reserved |
| Data RAM COE backing memory | `0x00010000` | `0x00010000` | 16,384 (Vivado-friendly power-of-two depth) |

The test uses the following RAM words (byte addresses):

| Address | Meaning |
|---|---|
| `0x00010000` | Status: `0x600D600D` = pass; `0xBAD00000 | test_id` = failure |
| `0x00010004` | Current test ID; remains the failing ID on failure |
| `0x00010008` | Completed test-group count; expected `20` on pass |
| `0x00010100` and above | Scratch words used by load/store tests |

In Vivado, watch the data-memory interface for writes to `0x00010004` and
`0x00010000`. A logic analyzer/waveform should show the test ID advancing from
1 through 20. On pass, the final status write is `0x600D600D` and the core loops
at `pass_halt`. On failure, the status write is `0xBAD00000 + test_id` and the
core loops at `fail_halt`.

If the data RAM is a separate block from instruction ROM, initialize each from
its own COE. The code writes its status words before testing and does not rely on
C startup behavior or preinitialized `.data` values.

## Coverage

1. ALU-to-ALU forwarding, dual source operands, and overwrite priority.
2. Chained RAW dependencies and immediate arithmetic consumers.
3. `x0`, sign extension of immediates, logical/arithmetic shifts.
4. ALU result to branch, taken/not-taken control flow, wrong-path squash.
5. Signed versus unsigned comparison around `0xffffffff`.
6. Store/load and load-use stall/forwarding.
7. Load immediately consumed by a branch.
8. ALU result to store data; immediate store-data dependency.
9. Load result to store data; immediate load-to-store dependency.
10. ALU result to store base address.
11. `LB/LBU/LH/LHU/SB/SH` sign extension and byte-lane behavior.
12. Back-to-back stores to the same address.
13. `JAL` target redirect, PC+4 link, fall-through squash.
14. `JALR` target forwarding, redirect, PC+4 link, fall-through squash.
15. Integer ALU/logical/immediate operations.
16. `LUI`, shift boundaries, and 32-bit wraparound.
17. Load result used immediately as a following load's base address.
18. One load feeding multiple consumers.
19. `SLT/SLTU`, equality, inequality.
20. Multiple-address load/store consistency.

## Notes / limitations

- All emitted instructions are 32-bit (`.option norvc`); this avoids compressed
  instruction assumptions in a minimal core.
- No software trap handler is installed. This is intentional: an illegal
  instruction or unsupported access may send a simple core off into a trap or
  undefined path rather than returning a test ID.
- The byte/halfword tests intentionally require standard RV32I load/store
  semantics and byte-write enables. If the core only implements `LW/SW`, test 11
  is expected to expose that limitation.
- This test checks architectural results, not every microarchitectural waveform
  signal. Pair the status signature with signals such as `pc`, `instr`, stall,
  forwarding selects, register-file write enable/address/data, branch-taken,
  data-memory address/write-enable/write-data, and load data.
- Do not connect the RAM COE to the instruction-memory port or vice versa unless
  your design intentionally implements a unified memory.
