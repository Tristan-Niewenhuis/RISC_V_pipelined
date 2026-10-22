OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00001000, LENGTH = 0x0000F000
    RAM (rwx) : ORIGIN = 0x00010000, LENGTH = 0x0000FFE0
}

SECTIONS
{
    /* Code lives in instruction ROM.  .init (= _start) must be at address 0. */
    .text :
    {
        . = ALIGN(4);
        KEEP(*(.init))
        KEEP(*(.text.startup))
        *(.text*)
        . = ALIGN(4);
    } > ROM

    /* Test mailbox: first word of RAM (0x00010000).  Initialised (zeros) so it
       is part of the RAM .coe file. */
    .mailbox :
    {
        . = ALIGN(4);
        KEEP(*(.mailbox))
        . = ALIGN(4);
    } > RAM

    /* Read-only data and initialised data both go to RAM (the CPU cannot read
       the instruction ROM as data), so they end up in ram.coe. */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata*)
        . = ALIGN(4);
    } > RAM

    .data :
    {
        . = ALIGN(4);
        __data_start__ = .;
        *(.data*)
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM

    /* Zero-initialised data: NOLOAD, not in the .coe.  The test program never
       reads bss before writing it. */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.sbss*)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    /* Stack top (unused by this test, kept for compatibility) */
    . = ORIGIN(RAM) + LENGTH(RAM);
    __StackTop  = .;
    __stack_top = .;

    __ram_start__ = ORIGIN(RAM);
    __ram_end__   = ORIGIN(RAM) + LENGTH(RAM);
    __rom_start__ = ORIGIN(ROM);
    __rom_end__   = ORIGIN(ROM) + LENGTH(ROM);

    ASSERT(__StackTop >= __bss_end__, "RAM overflow: data/bss collide with stack")
    ASSERT(. <= ORIGIN(RAM) + LENGTH(RAM), "RAM overflow")
    ASSERT(SIZEOF(.text) <= LENGTH(ROM), "ROM overflow")
}
