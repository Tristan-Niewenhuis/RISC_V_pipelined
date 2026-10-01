#!/bin/sh
# Analyse, elaborate and run the tightly_coupled_memory testbench under GHDL.
# Usage: RISC_V.srcs/sim_1/new/tcm/run_tcm_tb.sh
#
# Exits non-zero if any check fails.

set -e

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../../.." && pwd)
src="$root/RISC_V.srcs/sources_1/new"
work="${TMPDIR:-/tmp}/tcm_ghdl_work"

mkdir -p "$work"

# -frelaxed: BRAM inference needs a non-protected shared variable, which
# VHDL-2008 makes a warning rather than an error under this flag.
FLAGS="--std=08 -frelaxed --workdir=$work"

ghdl -a $FLAGS \
    "$src/RISCV_package.vhdl" \
    "$src/tightly_coupled_memory.vhdl" \
    "$here/tcm_tb.vhdl"

ghdl -e $FLAGS tcm_tb
exec ghdl -r $FLAGS tcm_tb -gINIT_DIR="$here/" --ieee-asserts=disable
