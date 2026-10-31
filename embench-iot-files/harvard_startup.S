.section .init
.global _start
.type _start, @function

_start:
    /*
     * Set stack pointer.
     */
    la sp, __StackTop


    /*
     * Clear .bss.
     */
    la t0, __bss_start__
    la t1, __bss_end__

bss_loop:
    bge t0, t1, bss_done

    sw zero, 0(t0)
    addi t0, t0, 4

    j bss_loop

bss_done:

    /*
     * Call C code.
     */
    jal ra, main             # a0 = main's return value

    beqz a0, report_done     # zero means pass
    li   t0, 0x0000FFE4      # cycle_hi register
    li   t1, 0xDEADBEEF
    sw   t1, 0(t0)           # mark verification failure

report_done:
    li   t0, 0x0000FFF0      # DONE/status register
    li   t1, 1
    sw   t1, 0(t0)           # tell the harness the run finished

hang:
    j hang