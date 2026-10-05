/*
 * tcm.ld -- linker script for RISC_V_TCM
 *
 * ITCM 0x00000000, 64 KB: code and read-only data.  The core reads the
 *      ITCM as data through ITCM port B, so .rodata needs no copy.
 * DTCM 0x10000000, 64 KB: initialized data, .bss, and the stack.  The
 *      DTCM init image (dtcm.hex) carries .data, so start.S does not
 *      copy it; it only clears .bss.
 *
 * elf2tcm.py turns the linked ELF into itcm.hex and dtcm.hex.
 */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ITCM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    DTCM (rw)  : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
    .text :
    {
        KEEP(*(.init))
        *(.text .text.*)
    } > ITCM

    .rodata :
    {
        . = ALIGN(4);
        *(.rodata .rodata.* .srodata .srodata.*)
        . = ALIGN(4);
    } > ITCM

    .data :
    {
        . = ALIGN(4);
        *(.data .data.* .sdata .sdata.*)
        . = ALIGN(4);
    } > DTCM

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss .bss.* .sbss .sbss.* COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > DTCM

    __stack_top = ORIGIN(DTCM) + LENGTH(DTCM);

    /DISCARD/ : { *(.comment) *(.riscv.attributes) }
}
