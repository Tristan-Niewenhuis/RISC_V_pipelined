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
    jal ra, main


hang:
    j hang