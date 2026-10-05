#!/bin/sh
# Build tcm_selftest for RISC_V_TCM, build the same C code for the host
# to get the expected result, and run it on the core under GHDL in both
# TCM timing modes.
# Usage: tcm_sw/run_tcm_selftest.sh
#
# Exits non-zero on a build failure, a result mismatch, or a timeout.

set -e

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
src="$root/RISC_V.srcs/sources_1/new"
sim="$root/RISC_V.srcs/sim_1/new/tcm_core"
work="${TMPDIR:-/tmp}/tcm_selftest_ghdl_work"
NM=${NM:-riscv32-unknown-elf-nm}

cd "$here"
make -s PROG=tcm_selftest

# Expected result: the same main(), built and run on the host
cat > build/host_main.c <<'EOF'
#include <stdio.h>
int tcm_main(void);
int main(void) { printf("%08X\n", (unsigned)tcm_main()); return 0; }
EOF
cc -O2 -Dmain=tcm_main -c tcm_selftest.c -o build/host_selftest.o
cc build/host_main.c build/host_selftest.o -o build/host_selftest
expect=$(./build/host_selftest)

addr() { $NM build/tcm_selftest.elf | awk -v s="$1" '$3 == s { print toupper($1) }'; }
# GHDL takes std_logic_vector generics on the command line only in binary
bin32() { python3 -c "print(format(int('$1', 16), '032b'))"; }
result_addr=$(addr tcm_result)
done_addr=$(addr tcm_done)
echo "expected $expect, tcm_result at $result_addr, tcm_done at $done_addr"

mkdir -p "$work"
# -frelaxed: BRAM inference needs a non-protected shared variable.
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
    "$src/RISC_V_TCM.vhdl" \
    "$sim/riscv_tcm_prog_tb.vhdl"

# The init images load at elaboration, relative to the current directory.
cd "$here/build"
ghdl -e $FLAGS riscv_tcm_prog_tb
for neg in false true; do
    ghdl -r $FLAGS riscv_tcm_prog_tb -gUSE_NEGEDGE=$neg -gINIT_DIR=./ \
        -gRESULT_ADDR="$(bin32 "$result_addr")" -gDONE_ADDR="$(bin32 "$done_addr")" \
        -gEXPECT="$(bin32 "$expect")" --ieee-asserts=disable
done
