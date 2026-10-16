/* =============================================================================
 * pipeline_test.S  --  RV32I pipeline / forwarding / hazard torture test
 *
 * Self-checking.  Stops at the FIRST failure and parks the core in a loop.
 *
 * REGISTER CONVENTION (harness-owned, never used by tests):
 *   x28 (t3) = current test ID           (changes at the start of every test)
 *   x29 (t4) = expected value of the last CHECK
 *   x30 (t5) = actual   value of the last CHECK (valid on failure)
 *   x31 (t6) = 0 while running, 0x600D600D = ALL PASS, 0xBAD0BAD0 = FAIL
 *   x26 (s10) = base of scratch RAM (bss)      } preserved by all tests
 *   x27 (s11) = base of initialised data words } (re-loaded after regfile test)
 *   x1..x9, x10..x17, x18..x25 are free for the tests.
 *
 * RAM MAILBOX (word 0 of RAM, i.e. 0x00010000 with the default linker script):
 *   +0  status   0 = running / 0x600D600D = pass / 0xBAD0BAD0 = fail
 *   +4  test ID  (fail: failing test, pass: total number of tests)
 *   +8  expected (fail only)
 *   +12 actual   (fail only)
 *   +16 return address of the failing CHECK (= PC of failing check's jal + 4)
 *
 * BUILD-TIME OPTIONS (-D...):
 *   GAP_NOPS=n       nops between tests (default 4).  Use 0 for back-to-back stress.
 *   CHECK_NOPS=n     nops between `li expected` and the compare in CHECK (default 3,
 *                    so the checker doesn't rely on forwarding).  0 = max stress.
 *   NO_LONG_JUMP     omit the ~6 KB nop block used to test long JAL offsets
 *   NO_JALR_LSB_TEST omit the (last) test that jalr clears bit 0 of its target
 *   TEST_CSR         add instret/cycle counter tests   (needs Zicntr in the core)
 *   TEST_CSR_RW      add CSR read-after-write hazard test using mscratch
 * =========================================================================== */

#ifndef GAP_NOPS
#define GAP_NOPS 4
#endif
#ifndef CHECK_NOPS
#define CHECK_NOPS 3
#endif

    .option norvc
    .option norelax

/* ------------------------------------------------------------------------- */
/* Macros                                                                    */
/* ------------------------------------------------------------------------- */

    .macro GAP
    .rept GAP_NOPS
    nop
    .endr
    .endm

    .set __tid, 0
    /* Start a new test: isolate with nops, bump ID, set t3, drop a label T_<name>
       (the Makefile turns these labels into build/tests.txt). */
    .macro TEST name
    GAP
    .set __tid, __tid + 1
T_\name:
    addi t3, x0, __tid
    .endm

    /* CHECK reg, imm : fail unless reg == imm.  Pass path = taken branch.
       CHECK_NOPS nops separate the `li t4` from the compare so the checker
       itself does not depend on forwarding (3 nops -> plain regfile read). */
    .macro CHECK reg, val
    li   t4, \val
    .rept CHECK_NOPS
    nop
    .endr
    beq  \reg, t4, 9f
    mv   t5, \reg
    jal  ra, test_fail
9:
    .endm

    /* CHECKR a, b : fail unless two registers are equal */
    .macro CHECKR a_, b_
    beq  \a_, \b_, 9f
    mv   t4, \b_
    mv   t5, \a_
    jal  ra, test_fail
9:
    .endm

    /* --- conditional-branch test macros -------------------------------------
       s8 ends = 1 when the branch was NOT taken, 2 when taken.
       The fall-through "addi s8,+1 ; j 2f" are the shadow instructions of a
       taken branch: if they ever commit, s8 != 2 -> fail.                     */

    /* A: operands from ALU, rs1 = d2, rs2 = d1 */
    .macro BRT_A op, va, vb, taken
    li   s8, 0
    li   s0, \va
    li   s1, \vb
    \op  s0, s1, 1f
    addi s8, s8, 1
    j    2f
1:  addi s8, s8, 2
2:  CHECK s8, 1+\taken
    .endm

    /* B: operands from ALU, rs1 = d1, rs2 = d2 */
    .macro BRT_B op, va, vb, taken
    li   s8, 0
    li   s1, \vb
    li   s0, \va
    \op  s0, s1, 1f
    addi s8, s8, 1
    j    2f
1:  addi s8, s8, 2
2:  CHECK s8, 1+\taken
    .endm

    /* L: operands come straight from loads (load-use into the branch).
       rs2 = d1 (stall needed), rs1 = d2.  Regs are poisoned with EQUAL values
       first so that a missing stall/forward shows up in one polarity.        */
    .macro BRT_L op, va, vb, taken
    li   s0, \va
    sw   s0, 0(s10)
    li   s1, \vb
    sw   s1, 4(s10)
    li   s0, 0x0F0F0F0F
    li   s1, 0x0F0F0F0F
    li   s8, 0
    lw   s0, 0(s10)
    lw   s1, 4(s10)
    \op  s0, s1, 1f
    addi s8, s8, 1
    j    2f
1:  addi s8, s8, 2
2:  CHECK s8, 1+\taken
    .endm

    /* M: loads, one nop in between: rs1 = d3, rs2 = d2 (no stall, MEM/WB fwd) */
    .macro BRT_M op, va, vb, taken
    li   s0, \va
    sw   s0, 8(s10)
    li   s1, \vb
    sw   s1, 12(s10)
    li   s0, 0x0F0F0F0F
    li   s1, 0x0F0F0F0F
    li   s8, 0
    lw   s0, 8(s10)
    lw   s1, 12(s10)
    nop
    \op  s0, s1, 1f
    addi s8, s8, 1
    j    2f
1:  addi s8, s8, 2
2:  CHECK s8, 1+\taken
    .endm

    .macro BRT op, va, vb, taken
    BRT_A \op, \va, \vb, \taken
    BRT_B \op, \va, \vb, \taken
    BRT_L \op, \va, \vb, \taken
    BRT_M \op, \va, \vb, \taken
    .endm

/* ------------------------------------------------------------------------- */
/* Boot  (placed first in ROM by the linker script: KEEP(*(.init)))          */
/* ------------------------------------------------------------------------- */
    .section .init, "ax"
    .globl _start
_start:
    .irp r, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    mv   x\r, x0                    /* no X's in the register file in simulation */
    .endr
    la   s10, scratch
    la   s11, data_words
    j    tests_start

/* ------------------------------------------------------------------------- */
/* Tests                                                                     */
/* ------------------------------------------------------------------------- */
    .text
    .balign 4
tests_start:

/* ============================ ALU FORWARDING ============================== */

    TEST alu_chain_d1
    /* EX/MEM -> EX forwarding, producer immediately before consumer */
    li   a0, 5
    addi a1, a0, 3          # rs1 d1
    addi a2, a1, 4
    addi a3, a2, 1
    add  a4, a3, a3         # same producer on rs1 AND rs2
    add  a5, a4, a3         # rs1 d1, rs2 d2
    sub  a6, a5, a4         # rs1 d1, rs2 d2 (non-commutative)
    CHECK a1, 8
    CHECK a2, 12
    CHECK a3, 13
    CHECK a4, 26
    CHECK a5, 39
    CHECK a6, 13

    TEST alu_dist_1_to_5
    /* producer->consumer distance 1,2,3 (MEM/WB fwd, regfile write-through),
       4,5 (plain regfile read) */
    li   a0, 0x100
    add  a1, a0, a0         # d1
    li   a2, 0x101
    nop
    add  a3, a2, a2         # d2
    li   a4, 0x102
    nop
    nop
    add  a5, a4, a4         # d3  (WB writes regfile in same cycle as ID reads)
    li   a6, 0x103
    nop
    nop
    nop
    add  a7, a6, a6         # d4
    li   s0, 0x104
    nop
    nop
    nop
    nop
    add  s1, s0, s0         # d5
    CHECK a1, 0x200
    CHECK a3, 0x202
    CHECK a5, 0x204
    CHECK a7, 0x206
    CHECK s1, 0x208

    TEST alu_rs2_only
    /* forwarding into the rs2 port only (rs1 = x0) at d1,d2,d3 */
    li   t0, 0x30
    sub  t1, x0, t0         # d1
    li   t0, 0x31
    nop
    sub  t2, x0, t0         # d2
    li   s2, 0x32
    nop
    nop
    sub  s3, x0, s2         # d3
    CHECK t1, -0x30
    CHECK t2, -0x31
    CHECK s3, -0x32

    TEST alu_two_src_combos
    /* different forwarding sources on rs1 / rs2.  sub is non-commutative so
       swapped operands are detected. Different constants per case so stale
       register-file data can't match by accident. */
    li   s1, 4              # c1: rs1 d1, rs2 d2
    li   s0, 21
    sub  s2, s0, s1
    li   s0, 31             # c2: rs1 d2, rs2 d1
    li   s1, 5
    sub  s3, s0, s1
    li   s0, 41             # c3: rs1 d3, rs2 d1
    nop
    li   s1, 6
    sub  s4, s0, s1
    li   s1, 7              # c4: rs1 d1, rs2 d3
    nop
    li   s0, 51
    sub  s5, s0, s1
    li   s0, 61             # c5: rs1 d3, rs2 d2
    li   s1, 8
    nop
    sub  s6, s0, s1
    li   s1, 9              # c6: rs1 d2, rs2 d3
    li   s0, 71
    nop
    sub  s7, s0, s1
    li   s0, 81             # c7: rs1 d4, rs2 d1
    nop
    nop
    li   s1, 10
    sub  s8, s0, s1
    li   s1, 11             # c8: rs1 d1, rs2 d4
    nop
    nop
    li   s0, 91
    sub  s9, s0, s1
    CHECK s2, 17
    CHECK s3, 26
    CHECK s4, 35
    CHECK s5, 44
    CHECK s6, 53
    CHECK s7, 62
    CHECK s8, 71
    CHECK s9, 80

    TEST fwd_priority_waw
    /* two in-flight writers of the same rd: youngest must win */
    li   s0, 1
    li   s0, 2
    li   s0, 3
    add  s1, s0, x0         # EX/MEM must beat MEM/WB -> 3
    li   s2, 11
    li   s2, 12
    nop
    add  s3, s2, x0         # younger is already in WB, older is gone -> 12
    li   s4, 21
    li   s4, 22
    nop
    nop
    add  s5, s4, x0         # -> 22
    lw   s6, 0(s11)         # older LOAD, younger ALU: ALU must win
    li   s6, 0x77
    add  s7, s6, x0         # -> 0x77
    li   s8, 0x66           # older ALU, younger LOAD: load must win (+stall)
    lw   s8, 4(s11)
    add  s9, s8, x0         # -> 0x80FF7F01
    CHECK s1, 3
    CHECK s3, 12
    CHECK s5, 22
    CHECK s7, 0x77
    CHECK s9, 0x80FF7F01

    TEST x0_never_forwarded
    /* writes to x0 must never be forwarded or stalled-on incorrectly */
    li   s0, 55
    addi x0, s0, 1          # would be 56
    add  s1, x0, x0         # d1 -> 0
    addi x0, x0, 7
    nop
    add  s2, x0, s0         # d2 -> 55
    lui  x0, 0xABCDE
    addi s3, x0, 9          # d1 -> 9
    li   s4, 3
    lw   x0, 0(s11)         # load into x0 ...
    add  s5, x0, s4         # ... then use -> 3
    lw   x0, 4(s11)
    addi s6, x0, 6          # -> 6
    auipc x0, 1
    sub  s7, x0, s4         # -> -3
    addi x0, s4, 1
    add  s8, s4, x0         # x0 on rs2, d1 -> 3
    CHECK s1, 0
    CHECK s2, 55
    CHECK s3, 9
    CHECK s5, 3
    CHECK s6, 6
    CHECK s7, -3
    CHECK s8, 3

    TEST alu_logic_arith_edges
    li   s0, 0xF0F0F0F0
    li   s1, 0x0FF00FF0
    and  s2, s0, s1
    or   s3, s0, s1
    xor  s4, s0, s1
    andi s5, s0, 0x7F0
    ori  s6, s0, 0x0F
    xori s7, s0, -1
    andi s8, s0, -16
    li   a0, 0x7FFFFFFF
    addi a1, a0, 1         # overflow wrap
    li   a2, 0
    addi a3, a2, -1
    add  a4, a3, a3
    sub  a5, a2, a1
    CHECK s2, 0x00F000F0
    CHECK s3, 0xFFF0FFF0
    CHECK s4, 0xFF00FF00
    CHECK s5, 0x000000F0
    CHECK s6, 0xF0F0F0FF
    CHECK s7, 0x0F0F0F0F
    CHECK s8, 0xF0F0F0F0
    CHECK a1, 0x80000000
    CHECK a3, 0xFFFFFFFF
    CHECK a4, 0xFFFFFFFE
    CHECK a5, 0x80000000

    TEST shift_fwd
    li   s0, 0x80000000
    li   s1, 33             # only low 5 bits (=1) are used
    srl  s2, s0, s1         # rs1 d2, rs2 d1
    sra  s3, s0, s1
    li   s4, 1
    li   s5, 35             # -> 3
    sll  s6, s4, s5
    srai s7, s0, 31         # imm shift, rs1 forwarded
    srli s8, s0, 31
    slli s9, s4, 31
    li   t0, 32             # shamt = 0
    srl  t1, s0, t0
    CHECK s2, 0x40000000
    CHECK s3, 0xC0000000
    CHECK s6, 8
    CHECK s7, 0xFFFFFFFF
    CHECK s8, 1
    CHECK s9, 0x80000000
    CHECK t1, 0x80000000

    TEST slt_fwd
    li   s0, -1
    li   s1, 1
    slt  s2, s0, s1         # 1
    sltu s3, s0, s1         # 0
    slt  s4, s1, s0         # 0
    sltu s5, s1, s0         # 1
    slti s6, s0, 0          # 1
    sltiu s7, s0, -1        # 0xFFFFFFFF < 0xFFFFFFFF -> 0
    sltiu s8, x0, 1         # 1  (seqz x0)
    CHECK s2, 1
    CHECK s3, 0
    CHECK s4, 0
    CHECK s5, 1
    CHECK s6, 1
    CHECK s7, 0
    CHECK s8, 1

    TEST lui_auipc
    lui  s0, 0x12345
    addi s1, s0, 0x678      # lui -> addi d1
    auipc s2, 0
    auipc s3, 0
    sub  s4, s3, s2         # = 4 (also tests auipc result forwarding)
    auipc s5, 1
    auipc s6, 0
    sub  s7, s5, s6         # = 0x1000 - 4
    lui  s8, 0xFFFFF
    srli s9, s8, 12
    CHECK s1, 0x12345678
    CHECK s4, 4
    CHECK s7, 0xFFC
    CHECK s9, 0x000FFFFF

    TEST regfile_all
    /* write every register x1..x27 back-to-back, then read all of them through
       both read ports */
    .irp r, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
    li   x\r, 0x01010101*\r
    .endr
    .irp r, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
    CHECK x\r, 0x01010101*\r
    .endr
    li   t5, 0
    .irp r, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
    add  t5, t5, x\r        # xr on rs2
    .endr
    CHECK t5, 0x7B7B7B7A
    li   t5, 0
    .irp r, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
    add  t5, x\r, t5        # xr on rs1
    .endr
    CHECK t5, 0x7B7B7B7A
    la   s10, scratch       # restore harness pointers
    la   s11, data_words

/* ========================= LOAD / STORE HAZARDS =========================== */

    TEST load_use_basic
    /* load -> use in the very next instruction (needs 1 stall bubble) */
    lw   s0, 0(s11)
    add  s1, x0, s0         # rs2
    lw   s2, 4(s11)
    add  s3, s2, x0         # rs1
    lw   s4, 0(s11)
    lw   s5, 8(s11)
    add  s6, s5, s4         # rs1 load-use d1, rs2 load d2
    lw   s7, 0(s11)
    add  s8, s7, s7         # both operands from the same load
    CHECK s1, 0x11223344
    CHECK s3, 0x80FF7F01
    CHECK s6, 0xEFCFF233
    CHECK s8, 0x22446688

    TEST load_use_dist
    lw   s0, 0(s11)
    nop
    add  s1, s0, s0         # d2 (MEM/WB fwd of load data)
    lw   s2, 8(s11)
    nop
    nop
    add  s3, s2, s2         # d3
    lw   s4, 4(s11)
    nop
    nop
    nop
    add  s5, s4, s4         # d4
    CHECK s1, 0x22446688
    CHECK s3, 0xBD5B7DDE
    CHECK s5, 0x01FEFE02

    TEST load_ptr_chase
    /* load whose result is the base address of the next load (rd == rs1) */
    lw   s0, 16(s11)        # -> &chain+20
    lw   s1, 0(s0)          # -> &chain+24
    lw   s2, 0(s1)          # -> &chain+28
    lw   s3, 0(s2)          # -> 0xC0FFEE00
    CHECK s3, 0xC0FFEE00
    lw   s4, 16(s11)
    lw   s4, 0(s4)
    lw   s4, 0(s4)
    lw   s4, 0(s4)
    CHECK s4, 0xC0FFEE00

    TEST load_to_store
    lw   s0, 8(s11)
    sw   s0, 0(s10)         # load -> store DATA, d1
    lw   s1, 0(s10)         # store -> load same addr, d1
    lw   s2, 0(s11)
    nop
    sw   s2, 4(s10)         # load -> store data, d2
    lw   s3, 4(s10)
    CHECK s1, 0xDEADBEEF
    CHECK s3, 0x11223344
    li   s6, 0xC0DE0001
    addi s4, s10, 100       # pointer kept in memory ...
    sw   s4, 8(s10)
    lw   s5, 8(s10)
    sw   s6, 0(s5)          # ... load -> store ADDRESS, d1
    lw   s7, 100(s10)
    CHECK s7, 0xC0DE0001

    TEST store_data_fwd
    li   s0, 0xA1
    sw   s0, 0(s10)         # data d1
    li   s1, 0xA2
    nop
    sw   s1, 4(s10)         # data d2
    li   s2, 0xA3
    nop
    nop
    sw   s2, 8(s10)         # data d3
    lw   s3, 0(s10)
    lw   s4, 4(s10)
    lw   s5, 8(s10)
    CHECK s3, 0xA1
    CHECK s4, 0xA2
    CHECK s5, 0xA3

    TEST store_addr_fwd
    addi s0, s10, 12        # address d1
    li   s1, 0xB4
    sw   s1, 0(s0)          # addr d2, data d1
    addi s2, s10, 16
    sw   s1, 0(s2)          # addr d1, data d2
    lw   s3, 12(s10)
    lw   s4, 16(s10)
    CHECK s3, 0xB4
    CHECK s4, 0xB4

    TEST store_load_alias
    li   s0, 0x55
    sw   x0, 20(s10)
    sw   s0, 16(s10)
    lw   s1, 20(s10)        # different address: must NOT see the store
    lw   s2, 16(s10)
    li   s3, 0x111
    li   s4, 0x222
    sw   s3, 24(s10)
    sw   s4, 24(s10)        # back-to-back stores, last wins
    lw   s5, 24(s10)
    sw   s3, 28(s10)
    lw   s6, 28(s10)        # store -> load d1
    sw   s4, 28(s10)
    lw   s7, 28(s10)
    sw   s3, 32(s10)
    nop
    lw   s8, 32(s10)        # d2
    sw   s4, 36(s10)
    nop
    nop
    lw   s9, 36(s10)        # d3
    CHECK s1, 0
    CHECK s2, 0x55
    CHECK s5, 0x222
    CHECK s6, 0x111
    CHECK s7, 0x222
    CHECK s8, 0x111
    CHECK s9, 0x222

    TEST subword_store_load
    sw   x0, 24(s10)
    li   s0, 0x11
    sb   s0, 24(s10)
    li   s1, 0x22
    sb   s1, 25(s10)
    li   s2, 0x33
    sb   s2, 26(s10)
    li   s3, 0x44
    sb   s3, 27(s10)
    lw   s4, 24(s10)        # all four byte lanes, immediately re-read
    li   s5, 0xBEEF
    sh   s5, 28(s10)
    li   s6, 0xCAFE
    sh   s6, 30(s10)
    lw   s7, 28(s10)        # both half lanes
    li   s0, 0x80
    sb   s0, 40(s10)
    lb   s1, 40(s10)        # sign-extend
    lbu  s2, 40(s10)        # zero-extend
    li   s0, 0x8001
    sh   s0, 44(s10)
    lh   s3, 44(s10)
    lhu  s5, 44(s10)
    li   s6, 0xAABBCCDD
    sw   s6, 48(s10)
    sb   x0, 49(s10)        # must not touch neighbours
    lw   s7, 48(s10)
    sh   x0, 50(s10)
    lw   s8, 48(s10)
    CHECK s4, 0x44332211
    CHECK s7, 0xAABB00DD
    CHECK s1, 0xFFFFFF80
    CHECK s2, 0x80
    CHECK s3, 0xFFFF8001
    CHECK s5, 0x8001
    CHECK s8, 0x000000DD
    lw   s9, 28(s10)
    CHECK s9, 0xCAFEBEEF

    TEST subword_load_ext
    /* data_words+4 = bytes 01 7F FF 80 */
    lb   s0, 4(s11)
    lb   s1, 5(s11)
    lb   s2, 6(s11)
    lb   s3, 7(s11)
    lbu  s4, 6(s11)
    lbu  s5, 7(s11)
    lh   s6, 4(s11)
    lh   s7, 6(s11)
    lhu  s8, 6(s11)
    CHECK s0, 1
    CHECK s1, 0x7F
    CHECK s2, 0xFFFFFFFF
    CHECK s3, 0xFFFFFF80
    CHECK s4, 0xFF
    CHECK s5, 0x80
    CHECK s6, 0x7F01
    CHECK s7, 0xFFFF80FF
    CHECK s8, 0x80FF
    /* same, with load-use d1 */
    lb   s0, 7(s11)
    add  s1, s0, s0
    lbu  s2, 7(s11)
    addi s3, s2, 1
    lh   s4, 6(s11)
    add  s5, s4, s4
    lhu  s6, 6(s11)
    addi s7, s6, 1
    CHECK s1, 0xFFFFFF00
    CHECK s3, 0x81
    CHECK s5, 0xFFFF01FE
    CHECK s7, 0x8100

    TEST mem_offsets
    li   s0, 0x1234ABCD
    sw   s0, 2044(s10)      # largest positive word offset
    addi s2, s10, 2044
    lw   s3, 0(s2)
    addi s2, s10, 2047
    addi s2, s2, 1          # s10 + 2048
    lw   s4, -4(s2)         # negative offset
    lw   s5, 2044(s10)
    sw   s0, -2048(s2)      # most negative offset (-> s10+0)
    lw   s6, 0(s10)
    CHECK s3, 0x1234ABCD
    CHECK s4, 0x1234ABCD
    CHECK s5, 0x1234ABCD
    CHECK s6, 0x1234ABCD

/* ======================== CONDITIONAL BRANCHES ============================ */
/* Each case is run 4 ways: ALU d2/d1, ALU d1/d2, load-use into branch,
   load d3/d2.  Last argument: 1 = must be taken, 0 = must not be taken.      */

    TEST br_beq
    BRT beq, 5, 5, 1
    BRT beq, 5, 6, 0
    BRT beq, -1, -1, 1
    BRT beq, 0x80000000, 0, 0
    BRT beq, 0, 0, 1

    TEST br_bne
    BRT bne, 5, 5, 0
    BRT bne, 5, 6, 1
    BRT bne, -1, 0, 1
    BRT bne, -1, -1, 0

    TEST br_blt
    BRT blt, -1, 1, 1
    BRT blt, 1, -1, 0
    BRT blt, 3, 3, 0
    BRT blt, 2, 3, 1
    BRT blt, 0x80000000, 0x7FFFFFFF, 1
    BRT blt, 0x7FFFFFFF, 0x80000000, 0

    TEST br_bge
    BRT bge, 1, -1, 1
    BRT bge, -1, 1, 0
    BRT bge, 3, 3, 1
    BRT bge, 0x7FFFFFFF, 0x80000000, 1
    BRT bge, 0x80000000, 0x7FFFFFFF, 0

    TEST br_bltu
    BRT bltu, 1, -1, 1
    BRT bltu, -1, 1, 0
    BRT bltu, 3, 3, 0
    BRT bltu, 0x7FFFFFFF, 0x80000000, 1
    BRT bltu, 0x80000000, 0x7FFFFFFF, 0

    TEST br_bgeu
    BRT bgeu, -1, 1, 1
    BRT bgeu, 1, -1, 0
    BRT bgeu, 3, 3, 1
    BRT bgeu, 0x80000000, 0x7FFFFFFF, 1
    BRT bgeu, 0x7FFFFFFF, 0x80000000, 0

    TEST br_same_reg
    /* both operands the very same forwarded register */
    li   s8, 0
    li   s0, 0x1234
    beq  s0, s0, 1f
    addi s8, s8, 1
    j    shadow_fail
1:  li   s1, 0x4321
    bne  s1, s1, 2f
    addi s8, s8, 2          # not taken -> executes
2:  CHECK s8, 2

/* ===================== CONTROL-FLOW FLUSH / SHADOW ======================== */

    TEST flush_branch_alu_shadow
    /* instructions in the shadow of a taken branch must not commit */
    li   s9, 0
    li   s0, 1
    li   s1, 1
    beq  s0, s1, 1f
    addi s9, s9, 1
    addi s9, s9, 1
    addi s9, s9, 1
    j    shadow_fail
1:  CHECK s9, 0
    /* shadow slot 1 = JAL (ID-stage redirect must lose to older branch) */
    li   s0, 2
    li   s1, 2
    beq  s0, s1, 1f
    j    shadow_fail
    j    shadow_fail
1:  /* shadow slot 2 = JAL */
    li   s0, 3
    li   s1, 3
    beq  s0, s1, 1f
    addi s9, s9, 1
    j    shadow_fail
    j    shadow_fail
1:  CHECK s9, 0
    /* shadow slot 1 = JALR */
    la   s2, shadow_fail
    li   s0, 4
    li   s1, 4
    beq  s0, s1, 1f
    jalr x0, 0(s2)
    jalr x0, 0(s2)
1:  /* shadow slot 1 = another TAKEN branch */
    li   s0, 5
    li   s1, 5
    beq  s0, s1, 1f
    beq  x0, x0, 8f
8:  j    shadow_fail
1:  CHECK s9, 0

    TEST flush_branch_mem_shadow
    /* shadow loads / stores must not commit or write registers */
    li   s0, 0x77
    sw   s0, 40(s10)
    li   s1, 0xBAD
    li   s9, 0
    beq  x0, x0, 1f
    sw   s1, 40(s10)
    sw   s1, 44(s10)
    sb   s1, 41(s10)
    lw   s9, 0(s11)
    j    shadow_fail
1:  lw   s2, 40(s10)
    lb   s3, 41(s10)
    CHECK s2, 0x77
    CHECK s9, 0
    CHECK s3, 0

    TEST flush_vs_loaduse_stall
    /* taken branch resolves while the shadow is stalled on a load-use */
    li   s9, 0
    sw   x0, 52(s10)
    beq  x0, x0, 1f
    lw   s9, 0(s11)
    add  s9, s9, s9         # would stall behind the lw
    sw   s9, 52(s10)
    j    shadow_fail
1:  lw   s2, 52(s10)
    CHECK s9, 0
    CHECK s2, 0

    TEST older_instr_commit
    /* instructions OLDER than a taken branch/jump must complete */
    li   s0, 0xA5A5
    sw   s0, 60(s10)        # store directly before taken branch
    beq  x0, x0, 1f
    j    shadow_fail
1:  lw   s4, 60(s10)
    addi s2, x0, 0x33       # ALU directly before taken branch
    beq  x0, x0, 2f
    j    shadow_fail
2:  lw   s3, 8(s11)         # load directly before taken branch
    beq  x0, x0, 3f
    j    shadow_fail
3:  li   s5, 0x1C3
    sw   s5, 64(s10)        # store directly before JAL
    j    4f
    j    shadow_fail
4:  lw   s6, 64(s10)
    lw   s7, 0(s11)         # load directly before JAL
    j    5f
    j    shadow_fail
5:  CHECK s4, 0xA5A5
    CHECK s2, 0x33
    CHECK s3, 0xDEADBEEF
    CHECK s6, 0x1C3
    CHECK s7, 0x11223344

    TEST br_to_br_chain
    /* taken branch whose target is itself a (taken / not-taken) branch */
    li   s0, 0
    beq  x0, x0, 1f
    li   s0, 0xBAD
1:  beq  x0, x0, 2f
    li   s0, 0xBAD
2:  bne  x0, x0, 3f
    addi s0, s0, 1
    beq  x0, x0, 4f
    li   s0, 0xBAD
3:  li   s0, 0xBAD
4:  jal  x0, 5f
    li   s0, 0xBAD
5:  beq  x0, x0, 6f
    li   s0, 0xBAD
6:  CHECK s0, 1

    TEST br_long_offsets
    /* exercises high bits of B-type immediate, forward and backward */
    li   s0, 0
    beq  x0, x0, 3f
    j    shadow_fail
1:  addi s0, s0, 1
    beq  x0, x0, 4f
    j    shadow_fail
    .rept 600
    nop
    .endr
3:  beq  x0, x0, 1b
    j    shadow_fail
4:  CHECK s0, 1
#ifndef NO_LONG_JUMP
    /* same with JAL, ~6 KB */
    li   s0, 0
    jal  x0, 3f
    j    shadow_fail
1:  addi s0, s0, 1
    jal  x0, 4f
    j    shadow_fail
    .rept 1500
    nop
    .endr
3:  jal  x0, 1b
    j    shadow_fail
4:  CHECK s0, 1
#endif

/* ============================ JAL / JALR ================================== */

    TEST jal_basic
    li   s9, 0
    jal  ra, 1f
2:  addi s9, s9, 1          # shadow (also = expected link address)
    j    shadow_fail
1:  mv   s0, ra             # link value consumed d1
    la   s1, 2b
    CHECKR s0, s1
    CHECKR ra, s1
    CHECK s9, 0

    TEST jal_chain
    /* jal -> jal -> jal back to back, plus nonstandard link regs */
    li   s9, 0
    jal  x0, 1f
    j    shadow_fail
1:  jal  x0, 2f
    j    shadow_fail
2:  jal  t0, 3f
    j    shadow_fail
3:  jal  x0, 4f
    j    shadow_fail
4:  CHECK s9, 0
    add  s0, t0, x0         # t0 = link of the third jal
    la   s1, 3b
    addi s1, s1, -4         # = address of the `j shadow_fail` after the jal t0
    CHECKR s0, s1

    TEST jal_flush_mem
    li   s0, 0x66
    sw   s0, 56(s10)
    li   s1, 0xBAD
    li   s9, 0
    j    1f
    sw   s1, 56(s10)
    addi s9, s9, 1
    lw   s9, 0(s11)
    j    shadow_fail
1:  lw   s2, 56(s10)
    CHECK s2, 0x66
    CHECK s9, 0

    TEST jalr_base_alu_fwd
    /* jalr base register produced by the instruction right before (la = auipc+addi) */
    li   s9, 0
    la   s0, 1f
    jalr ra, 0(s0)
2:  addi s9, s9, 1
    j    shadow_fail
1:  la   s1, 2b
    CHECKR ra, s1
    CHECK s9, 0
    /* jalr x0 with base from lui/addi pair */
    la   s0, 1f
    jalr x0, 0(s0)
    j    shadow_fail
    j    shadow_fail
1:  nop

    TEST jalr_offset
    la   s0, 1f
    addi s0, s0, -8
    jalr x0, 8(s0)          # base + imm
    j    shadow_fail
    j    shadow_fail
1:  la   s0, 3f
    addi s0, s0, 16
    jalr x0, -16(s0)        # negative immediate
    j    shadow_fail
3:  nop

    TEST jalr_load_base
    /* function-pointer table in RAM -> lw (load-use) -> jalr ; callee returns
       with `ret` (ra consumed d1 after the jalr in fn3) */
    li   s1, 0
    lw   s0, 32(s11)
    jalr ra, 0(s0)
    lw   s0, 36(s11)
    jalr ra, 0(s0)
    lw   s0, 40(s11)
    jalr ra, 0(s0)
    lw   s0, 44(s11)
    jalr ra, 0(s0)
    CHECK s1, 111

    TEST jalr_rd_eq_rs1
    la   s0, fn_ret_s0
    jalr s0, 0(s0)          # s0 <- link, jump via old s0
2:  la   s1, 2b
    CHECKR s0, s1

    TEST call_nested
    li   s1, 0
    jal  ra, fn_outer
    CHECK s1, 6
    li   s1, 0
    jal  ra, fn_outer
    jal  ra, fn_outer
    CHECK s1, 12

    TEST jalr_to_jalr
    la   s0, 1f
    la   s1, 2f
    jalr x0, 0(s0)
    j    shadow_fail
1:  jalr x0, 0(s1)          # target of a jalr is another jalr
    j    shadow_fail
2:  nop

/* =========================== LOOPS / STRESS =============================== */

    TEST loop_nested_sum
    li   s0, 0
    li   s3, 0
    li   s4, 4
2:  li   s1, 0
    li   s2, 10
1:  addi s1, s1, 1
    add  s3, s3, s1         # s1 d1
    bne  s1, s2, 1b         # taken 9x, not taken 1x
    addi s0, s0, 1
    bne  s0, s4, 2b
    CHECK s3, 220

    TEST loop_alternating
    /* taken / not-taken alternating every iteration (predictor killer) */
    li   s0, 0
    li   s1, 0
    li   s2, 16
1:  andi s3, s0, 1
    beqz s3, 2f             # ALU d1 into branch
    addi s1, s1, 3
    j    3f
2:  addi s1, s1, 1
3:  addi s0, s0, 1
    bne  s0, s2, 1b
    CHECK s1, 32

    TEST loop_popcount_pseudorandom
    /* data dependent branch pattern, popcount(0x9E3779B9) = 20 */
    li   s0, 0x9E3779B9
    li   s1, 0
    li   s2, 32
1:  andi s3, s0, 1
    srli s0, s0, 1
    beqz s3, 2f
    addi s1, s1, 1
2:  addi s2, s2, -1
    bnez s2, 1b
    CHECK s1, 20

    TEST fibonacci
    li   s0, 0
    li   s1, 1
    li   s2, 20
1:  add  s3, s0, s1
    mv   s0, s1
    mv   s1, s3
    addi s2, s2, -1
    bnez s2, 1b
    CHECK s0, 6765
    CHECK s1, 10946

    TEST xorshift32
    /* long ALU dependency chain with register reuse (s2 is WAW/RAW every step) */
    li   s0, 0x12345678
    li   s1, 32
1:  slli s2, s0, 13
    xor  s0, s0, s2
    srli s2, s0, 17
    xor  s0, s0, s2
    slli s2, s0, 5
    xor  s0, s0, s2
    addi s1, s1, -1
    bnez s1, 1b
    CHECK s0, 0xF803D0AC

    TEST array_sum_memcpy
    addi s1, s10, 256       # src
    li   s0, 0
    li   s2, 8
1:  addi s0, s0, 1
    sw   s0, 0(s1)          # store data d1
    addi s1, s1, 4
    bne  s0, s2, 1b
    addi s1, s10, 256
    li   s0, 0
    li   s3, 0
1:  lw   s4, 0(s1)
    add  s3, s3, s4         # load-use in a loop
    addi s1, s1, 4
    addi s0, s0, 1
    bne  s0, s2, 1b
    CHECK s3, 36
    addi s1, s10, 256       # memcpy src -> dst
    addi s5, s10, 320
    li   s0, 0
1:  lw   s4, 0(s1)
    sw   s4, 0(s5)          # load-use into store data
    addi s1, s1, 4
    addi s5, s5, 4
    addi s0, s0, 1
    bne  s0, s2, 1b
    addi s5, s10, 320
    li   s0, 0
    li   s3, 0
1:  lw   s4, 0(s5)
    add  s3, s3, s4
    addi s5, s5, 4
    addi s0, s0, 1
    bne  s0, s2, 1b
    CHECK s3, 36

    TEST bubble_sort
    /* loads, stores, store->load aliasing, branches, all dependent */
    li   s0, 5
    sw   s0, 384(s10)
    li   s0, 2
    sw   s0, 388(s10)
    li   s0, 8
    sw   s0, 392(s10)
    li   s0, 1
    sw   s0, 396(s10)
    li   s0, 9
    sw   s0, 400(s10)
    li   s0, 3
    sw   s0, 404(s10)
    li   s0, 7
    sw   s0, 408(s10)
    li   s0, 4
    sw   s0, 412(s10)
    li   s0, 7              # outer pass count
2:  li   s1, 0
    addi s2, s10, 384
1:  lw   s3, 0(s2)
    lw   s4, 4(s2)
    bge  s4, s3, 3f         # in order -> no swap
    sw   s4, 0(s2)
    sw   s3, 4(s2)
3:  addi s2, s2, 4
    addi s1, s1, 1
    bne  s1, s0, 1b
    addi s0, s0, -1
    bnez s0, 2b
    lw   s3, 384(s10)
    CHECK s3, 1
    lw   s3, 388(s10)
    CHECK s3, 2
    lw   s3, 392(s10)
    CHECK s3, 3
    lw   s3, 396(s10)
    CHECK s3, 4
    lw   s3, 400(s10)
    CHECK s3, 5
    lw   s3, 404(s10)
    CHECK s3, 7
    lw   s3, 408(s10)
    CHECK s3, 8
    lw   s3, 412(s10)
    CHECK s3, 9

#ifdef TEST_CSR
/* ======================= PERFORMANCE COUNTERS (opt.) ====================== */
    TEST csr_instret_count
    /* assumes instret counts RETIRED instructions and a csrr sees all older ones */
    csrr s0, instret
    nop
    nop
    nop
    nop
    csrr s1, instret
    sub  s2, s1, s0         # csrr + 4 nops = 5
    CHECK s2, 5
    csrr s0, instret
    beq  x0, x0, 1f
    nop                     # flushed instructions must NOT be counted
    nop
    nop
1:  csrr s1, instret
    sub  s2, s1, s0         # csrr + beq = 2
    CHECK s2, 2
    csrr s0, instret
    lw   a0, 0(s11)
    addi a1, a0, 1          # load-use stall bubble must NOT be counted
    csrr s1, instret
    sub  s2, s1, s0         # csrr + lw + addi = 3
    CHECK s2, 3

    TEST csr_cycle_monotonic
    csrr s0, cycle
    nop
    nop
    nop
    nop
    csrr s1, cycle
    sub  s2, s1, s0
    slti s3, s2, 5          # >= 5 cycles for 5 instructions
    CHECK s3, 0
#endif

#ifdef TEST_CSR_RW
    TEST csr_rw_hazard
    li   s0, 0x1234ABCD
    csrw mscratch, s0       # csr write data forwarded d1
    csrr s1, mscratch       # read-after-write
    addi s2, s1, 1          # csr read result used d1
    csrrw s3, mscratch, s2  # swap, write data forwarded d1
    csrr s4, mscratch
    CHECK s1, 0x1234ABCD
    CHECK s2, 0x1234ABCE
    CHECK s3, 0x1234ABCD
    CHECK s4, 0x1234ABCE
#endif

#ifndef NO_JALR_LSB_TEST
    /* Kept LAST: a core that does not clear bit 0 of the jalr target will fetch
       from a misaligned address here (hang / garbage) instead of failing cleanly. */
    TEST jalr_lsb_clear
    la   s0, 2f
    addi s0, s0, 1
    jalr x0, 0(s0)          # bit 0 of target must be cleared
    j    shadow_fail
2:  la   s0, 3f
    addi s0, s0, -2
    jalr x0, 3(s0)          # (base + imm) & ~1
    j    shadow_fail
3:  nop
#endif

/* ------------------------------------------------------------------------- */
/* End of tests                                                              */
/* ------------------------------------------------------------------------- */
/* The reporting code below keeps nops between every dependent pair so that it
   still works when the forwarding / hazard logic under test is broken. */
    .macro SAFE
    .rept 4
    nop
    .endr
    .endm

test_pass:
    lui  t5, %hi(mailbox)
    SAFE
    addi t5, t5, %lo(mailbox)
    lui  t6, %hi(0x600D600D)
    SAFE
    addi t6, t6, %lo(0x600D600D)   # x31 = PASS
    SAFE
    sw   t3, 4(t5)          # number of tests run
    sw   t6, 0(t5)
pass_forever:
    j    pass_forever

test_fail:                  # ra = return address of failing CHECK
    lui  t6, %hi(mailbox)
    SAFE
    addi t6, t6, %lo(mailbox)
    lui  t2, %hi(0xBAD0BAD0)
    SAFE
    addi t2, t2, %lo(0xBAD0BAD0)
    SAFE
    sw   t3, 4(t6)          # failing test ID
    sw   t4, 8(t6)          # expected
    sw   t5, 12(t6)         # actual
    sw   ra, 16(t6)         # PC of failing failing CHECK jal + 4
    sw   t2, 0(t6)          # status word last (a testbench can poll it)
    mv   t6, t2             # x31 = FAIL (0xBAD0BAD0)
fail_forever:
    j    fail_forever

shadow_fail:                # reached only if a flushed instruction executed
    lui  t4, %hi(0xBAD5AD00)
    SAFE
    addi t4, t4, %lo(0xBAD5AD00)
    li   t5, 0
    jal  ra, test_fail

/* ------------------------------------------------------------------------- */
/* Callee functions (used by jalr tests)                                     */
/* ------------------------------------------------------------------------- */
    .balign 4
fn0:    addi s1, s1, 1
        ret
fn1:    addi s1, s1, 10
        ret
fn2:    addi s1, s1, 100
        ret
fn3:    ret                 # ret as FIRST instruction: ra is d1 from the jalr
fn_ret_s0:
        jalr x0, 0(s0)      # return through s0 (s0 produced by the jalr, d1)
fn_outer:
        mv   s2, ra
        jal  ra, fn_inner
        addi s1, s1, 1
        jalr x0, 0(s2)
fn_inner:
        addi s1, s1, 5
        ret

/* ------------------------------------------------------------------------- */
/* RAM contents                                                              */
/* ------------------------------------------------------------------------- */
    .section .mailbox, "aw", @progbits
    .balign 4
    .globl mailbox
mailbox:
    .word 0, 0, 0, 0, 0, 0, 0, 0

    .section .data
    .balign 4
    .globl data_words
data_words:
    .word 0x11223344        # +0
    .word 0x80FF7F01        # +4   bytes 01 7F FF 80
    .word 0xDEADBEEF        # +8
    .word 0x00000010        # +12
    .word data_words + 20   # +16  pointer chain
    .word data_words + 24   # +20
    .word data_words + 28   # +24
    .word 0xC0FFEE00        # +28
    .word fn0               # +32  function pointer table (ROM addresses)
    .word fn1               # +36
    .word fn2               # +40
    .word fn3               # +44

    .section .bss
    .balign 4
    .globl scratch
scratch:
    .space 4096
