# Single-cycle reference core

A single-cycle RV32I core built from the same decoder, ALU, BTU, CSRs, and
memories as the pipelined core, used as a reference point in the paper.
Every instruction takes one cycle except a load, which takes two because
the data BRAM read is synchronous.

The files here add new entities only, so they cannot replace any part of
the pipelined core:

| File | Entity | What it is |
|---|---|---|
| `risc_v_tcm_sc.vhdl` | `RISC_V_TCM_SC` | `RISC_V_TCM` with `Datapath_SC` in place of `Datapath` |
| `datapath_sc.vhdl` | `Datapath_SC` | the single-cycle datapath |
| `register_file_sc.vhdl` | `register_file_sc` | `generic_register_file` without the write-through bypass |

They use the packages and components in `RISC_V.srcs/sources_1/new`
unchanged.  To build the single-cycle core, add these three files to the
project and point the `RISC_V_TCM_0` module reference in the block design
at `RISC_V_TCM_SC` instead of `RISC_V_TCM`.

Measured on the Nexys A7-100T with the performance-oriented Vivado
settings and `DEBUG` false: Fmax 76.41 MHz, geometric-mean CPI 1.134 on
Embench-IoT, 67.4 MIPS.  All 19 benchmarks pass on the board.
