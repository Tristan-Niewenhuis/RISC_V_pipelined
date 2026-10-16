OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00010000
    RAM (rwx) : ORIGIN = 0x00010000, LENGTH = 0x0000FFE0
}

SECTIONS
{
    /* Fetchable instructions live in the instruction ROM. */
    .text ORIGIN(ROM) :
    {
        . = ALIGN(4);
        KEEP(*(.text.startup))
        KEEP(*(.init))
        *(.text .text.*)
        . = ALIGN(4);
    } > ROM

    /* Match the reference memory map: constants and writable data live in RAM. */
    .rodata ORIGIN(RAM) :
    {
        . = ALIGN(4);
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        . = ALIGN(4);
    } > RAM

    .data :
    {
        . = ALIGN(4);
        __data_start__ = .;
        *(.data .data.*)
        *(.sdata .sdata.*)
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    /* No C runtime is used; stack symbols are provided for compatibility. */
    __StackTop  = ORIGIN(RAM) + LENGTH(RAM);
    __stack_top = __StackTop;
    __ram_start__ = ORIGIN(RAM);
    __ram_end__   = ORIGIN(RAM) + LENGTH(RAM);
    __rom_start__ = ORIGIN(ROM);
    __rom_end__   = ORIGIN(ROM) + LENGTH(ROM);

    ASSERT(SIZEOF(.text) <= LENGTH(ROM), "ROM overflow")
    ASSERT(__bss_end__ <= __StackTop, "RAM overflow: data/bss collide with stack")
}
