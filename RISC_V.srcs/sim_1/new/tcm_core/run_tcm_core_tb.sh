#!/bin/sh
# Run the RISC_V_TCM instruction regression under GHDL in both TCM
# timing modes, each with the peripheral read latency at 0 and 3 cycles.
# Usage: RISC_V.srcs/sim_1/new/tcm_core/run_tcm_core_tb.sh
#
# Exits non-zero if any check fails in either mode.

set -e

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../../.." && pwd)
src="$root/RISC_V.srcs/sources_1/new"
work="${TMPDIR:-/tmp}/tcm_core_ghdl_work"

mkdir -p "$work"

# The init images load at elaboration, relative to the current directory
# unless INIT_DIR says otherwise, so run from this directory.
cd "$here"

# -frelaxed: BRAM inference needs a non-protected shared variable, which
# VHDL-2008 makes a warning rather than an error under this flag.
FLAGS="--std=08 -frelaxed --workdir=$work"

ghdl -a $FLAGS \
    "$src/RISCV_package.vhdl" \
    "$src/generic_register.vhdl" \
    "$src/generic_counter.vhdl" \
    "$src/generic_register_file.vhdl" \
    "$src/generic_shifter.vhdl" \
    "$src/generic_CSR.vhdl" \
    "$src/CSR_regs.vhdl" \
    "$src/ALU.vhdl" \
    "$src/btu.vhdl" \
    "$src/Instruction_Decoder.vhdl" \
    "$src/datapath.vhdl" \
    "$src/Load_Store.vhdl" \
    "$src/tightly_coupled_memory.vhdl" \
    "$src/axi_lite_master.vhdl" \
    "$src/RISC_V_TCM.vhdl" \
    "$here/axi_mem_sim.vhdl" \
    "$here/riscv_tcm_tb.vhdl"

ghdl -e $FLAGS riscv_tcm_tb

for neg in false true; do
    for lat in 0 3; do
        ghdl -r $FLAGS riscv_tcm_tb -gUSE_NEGEDGE=$neg -gPERIPH_LATENCY=$lat \
            -gINIT_DIR="$here/" --ieee-asserts=disable
    done
done
