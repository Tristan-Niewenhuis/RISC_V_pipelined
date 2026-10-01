/*
 * start.S -- reset entry for RISC_V_TCM programs (see tcm.ld)
 *
 * Sets the stack pointer, clears .bss, and calls main.  When main
 * returns, its return value is stored to tcm_result and tcm_done is
 * set to 1, so a testbench can watch the DTCM stores for the result.
 * Then the core spins.
 */
    .section .init
    .globl _start
_start:
    la      sp, __stack_top

    la      t0, __bss_start
    la      t1, __bss_end
1:  bgeu    t0, t1, 2f
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       1b
2:
    call    main

    la      t0, tcm_result
    sw      a0, 0(t0)
    la      t0, tcm_done
    li      t1, 1
    sw      t1, 0(t0)
3:  j       3b

    .section .bss
    .balign 4
    .globl tcm_result
tcm_result: .word 0
    .globl tcm_done
tcm_done:   .word 0
