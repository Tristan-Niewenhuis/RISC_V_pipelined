/*
 * RV32I pipeline / forwarding stress test for a small in-order RISC-V core.
 *
 * All instructions are 32-bit: compressed instructions are explicitly disabled.
 * No C runtime, stack, CSR, timer, M-extension, or floating-point support is used.
 *
 * RAM status words (RAM origin = 0x00010000):
 *   0x00010000  status: 0x600D600D on pass; 0xBAD00000 | test_id on failure
 *   0x00010004  current / failing test ID
 *   0x00010008  number of completed test groups
 * Scratch memory is at 0x00010100 and above.
 *
 * In the waveform, watch data-memory writes where address == 0x00010004 or
 * address == 0x00010000. The current-test ID updates at each group boundary.
 */

    .option norvc
    .option norelax

    .equ RAM_BASE,       0x00010000
    .equ STATUS_ADDR,    0x00010000
    .equ TEST_ID_ADDR,   0x00010004
    .equ PASS_COUNT_ADDR,0x00010008
    .equ SCRATCH_BASE,   0x00010100
    .equ PASS_MAGIC,     0x600D600D

    .macro begin test_id
        li      s2, \test_id
        sw      s2, 4(s0)
    .endm

    .macro passed
        addi    s1, s1, 1
        sw      s1, 8(s0)
    .endm

    .section .text.startup,"ax",@progbits
    .align  2
    .globl  _start
    .type   _start,@function
_start:
    /* Signature/status area and registers. */
    li      s0, RAM_BASE
    li      s1, 0                  /* completed test groups */
    li      s2, 0                  /* test ID, preserved until fail */
    li      s3, SCRATCH_BASE       /* test scratch base */
    sw      zero, 0(s0)
    sw      zero, 4(s0)
    sw      zero, 8(s0)

/* ------------------------------------------------------------------------- */
/* 01: ALU -> ALU forwarding, both source operands, and ordinary ADD result. */
/* ------------------------------------------------------------------------- */
    begin   1
    addi    t0, zero, 7
    addi    t1, zero, 11
    add     t2, t0, t1             /* one operand newer than the other */
    addi    t3, zero, 18
    bne     t2, t3, fail
    passed

/* ------------------------------------------------------------------------- */
/* 02: Tight RAW chain and repeated writes to the same destination register. */
/* ------------------------------------------------------------------------- */
    begin   2
    addi    t0, zero, 1
    addi    t0, t0, 2
    addi    t0, t0, 4
    addi    t1, t0, 1
    addi    t2, zero, 8
    bne     t1, t2, fail
    passed

/* ------------------------------------------------------------------------- */
/* 03: x0 hard-wiring, signed immediates, logical vs arithmetic right shift. */
/* ------------------------------------------------------------------------- */
    begin   3
    addi    zero, zero, 123
    addi    t0, zero, -1
    srli    t1, t0, 1
    srai    t2, t0, 1
    lui     t3, 0x80000            /* 0x80000000 is negative as signed RV32 */
    bge     t3, zero, fail
    lui     t4, 0x80000
    addi    t4, t4, -1             /* 0x7fffffff */
    bne     t1, t4, fail
    bne     t2, t0, fail           /* 0xffffffff */
    passed

/* ------------------------------------------------------------------------- */
/* 04: ALU result used immediately by a branch; taken and not-taken paths.    */
/* ------------------------------------------------------------------------- */
    begin   4
    addi    t4, zero, 0
    addi    t0, zero, 0x31
    addi    t1, t0, 0              /* t1 must get the just-produced t0 */
    beq     t1, t0, test04_taken
    addi    t4, zero, 0x55         /* must be squashed on taken branch */
test04_taken:
    bne     t4, zero, fail
    bne     t1, t0, fail           /* deliberately not taken */
    addi    t5, zero, 7
    addi    t6, zero, 7
    bne     t5, t6, fail
    passed

/* ------------------------------------------------------------------------- */
/* 05: Signed and unsigned comparisons at the sign boundary.                 */
/* ------------------------------------------------------------------------- */
    begin   5
    addi    t0, zero, -1           /* signed -1, unsigned 0xffffffff */
    addi    t1, zero, 1
    blt     t0, t1, test05_signed_lt
    j       fail
test05_signed_lt:
    bge     t0, t1, fail
    bltu    t0, t1, fail
    bgeu    t0, t1, test05_unsigned_ge
    j       fail
test05_unsigned_ge:
    passed

/* ------------------------------------------------------------------------- */
/* 06: Store -> load -> immediate consumer (load-use interlock/forwarding).   */
/* ------------------------------------------------------------------------- */
    begin   6
    addi    t0, zero, 0x135
    sw      t0, 0(s3)
    lw      t1, 0(s3)
    addi    t2, t1, 7              /* immediate load-use dependency */
    addi    t3, zero, 0x13c
    bne     t2, t3, fail
    passed

/* ------------------------------------------------------------------------- */
/* 07: Load immediately followed by a branch that consumes the loaded value. */
/* ------------------------------------------------------------------------- */
    begin   7
    addi    t0, zero, 0x246
    addi    t1, zero, 0x246
    sw      t0, 4(s3)
    lw      t2, 4(s3)
    beq     t2, t1, test07_branch_ok
    addi    t4, zero, 99           /* must be squashed on taken branch */
test07_branch_ok:
    bne     t4, zero, fail
    passed

/* ------------------------------------------------------------------------- */
/* 08: ALU result used as store data in the immediately following instruction.*/
/* ------------------------------------------------------------------------- */
    begin   8
    sw      zero, 8(s3)
    addi    t0, zero, 0x5a
    sw      t0, 8(s3)              /* store-data forwarding path */
    lw      t1, 8(s3)
    addi    t2, zero, 0x5a
    bne     t1, t2, fail
    passed

/* ------------------------------------------------------------------------- */
/* 09: Load result consumed immediately as store data (load-to-store path).   */
/* ------------------------------------------------------------------------- */
    begin   9
    lw      t0, 0(s3)
    sw      t0, 12(s3)
    lw      t1, 12(s3)
    addi    t2, zero, 0x135
    bne     t1, t2, fail
    passed

/* ------------------------------------------------------------------------- */
/* 10: Freshly computed base address consumed immediately by a store.         */
/* ------------------------------------------------------------------------- */
    begin   10
    addi    t0, zero, 0x6b
    addi    t1, s3, 16
    sw      t0, 0(t1)              /* rs1/base forwarding */
    lw      t2, 16(s3)
    bne     t2, t0, fail
    passed

/* ------------------------------------------------------------------------- */
/* 11: LB/LBU/LH/LHU sign extension plus SB/SH byte-enable/lane correctness.  */
/* ------------------------------------------------------------------------- */
    begin   11
    lui     t0, 0x80ff8
    addi    t0, t0, -255           /* 0x80ff7f01 */
    sw      t0, 32(s3)
    lb      t1, 35(s3)             /* 0x80 -> -128 */
    addi    t2, zero, -128
    bne     t1, t2, fail
    lbu     t1, 35(s3)
    addi    t2, zero, 128
    bne     t1, t2, fail
    lh      t1, 34(s3)             /* upper half = 0x80ff, signed */
    /* Build signed expected value explicitly: 0x80ff - 0x10000 = -32513. */
    lui     t2, 0xffff8
    addi    t2, t2, 0x0ff
    bne     t1, t2, fail
    lhu     t1, 34(s3)
    lui     t2, 0x8
    addi    t2, t2, 0x0ff
    bne     t1, t2, fail
    sw      zero, 40(s3)
    addi    t0, zero, 0xa5
    sb      t0, 41(s3)
    lui     t1, 0x0000a
    addi    t1, t1, 0x500
    lw      t2, 40(s3)
    bne     t2, t1, fail
    addi    t0, zero, 0x123
    sh      t0, 42(s3)
    /* 0x0123A500 is assembled as 0x0123A000 + 0x500. */
    lui     t1, 0x0123a
    addi    t1, t1, 0x500
    lw      t2, 40(s3)
    bne     t2, t1, fail
    passed

/* ------------------------------------------------------------------------- */
/* 12: Back-to-back stores to one word; newest store must win.                */
/* ------------------------------------------------------------------------- */
    begin   12
    addi    t0, zero, 0x11
    sw      t0, 44(s3)
    addi    t0, zero, 0x22
    sw      t0, 44(s3)
    lw      t1, 44(s3)
    addi    t2, zero, 0x22
    bne     t1, t2, fail
    passed

/* ------------------------------------------------------------------------- */
/* 13: JAL redirect, link value (PC+4), and flushing of fall-through.         */
/* ------------------------------------------------------------------------- */
    begin   13
    addi    t4, zero, 0
    jal     t0, test13_jal_target
test13_jal_link_addr:
    addi    t4, zero, 99           /* wrong path; must be squashed */
test13_jal_verify:
    la      t1, test13_jal_link_addr
    bne     t0, t1, fail           /* JAL rd must contain the PC+4 address */
    bne     t4, zero, fail
    passed
    j       test14_start
test13_jal_target:
    j       test13_jal_verify

/* ------------------------------------------------------------------------- */
/* 14: JALR redirect/link plus fresh AUIPC/ADDI-produced target register.     */
/* ------------------------------------------------------------------------- */
test14_start:
    begin   14
    addi    t4, zero, 0
    la      t1, test14_jalr_target
    jalr    t0, 0(t1)              /* target register used immediately */
test14_jalr_link_addr:
    addi    t4, zero, 99           /* wrong path; must be squashed */
test14_jalr_verify:
    la      t2, test14_jalr_link_addr
    bne     t0, t2, fail           /* JALR rd must contain the PC+4 address */
    bne     t4, zero, fail
    passed
    j       test15_start
test14_jalr_target:
    j       test14_jalr_verify

/* ------------------------------------------------------------------------- */
/* 15: Integer ALU operations and immediate decode.                           */
/* ------------------------------------------------------------------------- */
test15_start:
    begin   15
    addi    t0, zero, 0x55
    xori    t1, t0, 0xff           /* 0xaa */
    addi    t2, zero, 0xaa
    bne     t1, t2, fail
    ori     t1, t0, 0x0f            /* 0x5f */
    addi    t2, zero, 0x5f
    bne     t1, t2, fail
    andi    t1, t0, 0x0f            /* 0x05 */
    addi    t2, zero, 5
    bne     t1, t2, fail
    slli    t1, t0, 2               /* 0x154 */
    addi    t2, zero, 0x154
    bne     t1, t2, fail
    slti    t1, t0, 0x60
    addi    t2, zero, 1
    bne     t1, t2, fail
    passed

/* ------------------------------------------------------------------------- */
/* 16: LUI/ADDI, carry wrap, and shift behavior at 32-bit boundaries.         */
/* ------------------------------------------------------------------------- */
    begin   16
    lui     t0, 0x12345
    addi    t0, t0, 0x678           /* 0x12345678 */
    srli    t1, t0, 4               /* 0x01234567 */
    lui     t2, 0x01234
    addi    t2, t2, 0x567
    bne     t1, t2, fail
    slli    t3, t1, 4               /* 0x12345670 */
    lui     t4, 0x12345
    addi    t4, t4, 0x670
    bne     t3, t4, fail
    addi    t5, zero, -1
    addi    t5, t5, 1
    bne     t5, zero, fail
    passed

/* ------------------------------------------------------------------------- */
/* 17: Load result used as the very next load's base address.                  */
/* ------------------------------------------------------------------------- */
    begin   17
    addi    t0, s3, 60
    sw      t0, 52(s3)              /* store pointer */
    addi    t1, zero, 0x3d
    sw      t1, 0(t0)
    lw      t2, 52(s3)
    lw      t3, 0(t2)               /* load-use dependency in rs1/base */
    addi    t4, zero, 0x3d
    bne     t3, t4, fail
    passed

/* ------------------------------------------------------------------------- */
/* 18: One load feeding two consumers, with different distances/forward paths. */
/* ------------------------------------------------------------------------- */
    begin   18
    lw      t0, 0(s3)
    addi    t1, t0, 1
    addi    t2, t0, 2
    addi    t3, zero, 0x136
    bne     t1, t3, fail
    addi    t3, zero, 0x137
    bne     t2, t3, fail
    passed

/* ------------------------------------------------------------------------- */
/* 19: SLTU/SLT and equality/inequality corner cases.                           */
/* ------------------------------------------------------------------------- */
    begin   19
    addi    t0, zero, -1
    slt     t1, t0, zero            /* -1 < 0 signed -> 1 */
    addi    t2, zero, 1
    bne     t1, t2, fail
    sltu    t1, t0, zero            /* 0xffffffff < 0 unsigned -> 0 */
    bne     t1, zero, fail
    addi    t3, zero, 0
    beq     t3, zero, test19_eq_ok
    j       fail
test19_eq_ok:
    bne     t3, zero, fail
    passed

/* ------------------------------------------------------------------------- */
/* 20: Store/load at multiple offsets and final memory consistency check.    */
/* ------------------------------------------------------------------------- */
    begin   20
    addi    t0, zero, 0x12
    sw      t0, 64(s3)
    addi    t0, zero, 0x34
    sw      t0, 68(s3)
    addi    t0, zero, 0x56
    sw      t0, 72(s3)
    lw      t1, 64(s3)
    lw      t2, 68(s3)
    lw      t3, 72(s3)
    addi    t4, zero, 0x12
    bne     t1, t4, fail
    addi    t4, zero, 0x34
    bne     t2, t4, fail
    addi    t4, zero, 0x56
    bne     t3, t4, fail
    passed

/* All 20 groups passed. Keep the result stable for waveform inspection. */
    lui     t6, 0x600d6
    addi    t6, t6, 0x00d
    sw      t6, 0(s0)
pass_halt:
    j       pass_halt

/* A failure records BAD00000 | test_id and then halts. */
fail:
    sw      s2, 4(s0)
    lui     t6, 0xBAD00
    add     t6, t6, s2
    sw      t6, 0(s0)
fail_halt:
    j       fail_halt

    .size _start, . - _start
