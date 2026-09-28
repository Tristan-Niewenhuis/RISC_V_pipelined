OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x80000000, LENGTH = 0x00001000
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00001000
}

SECTIONS
{
    /*
     * Code lives in instruction ROM.
     */
    .text :
    {
        . = ALIGN(4);

        KEEP(*(.init))
        KEEP(*(.text.startup))
        *(.text*)
        
        . = ALIGN(4);
    } > ROM


    /*
     * This assumes initializes RAM with the contents
     * specified by the ELF image.
     */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata*)
        . = ALIGN(4);
    } > RAM


    /*
     * Initialized writable data.
     *
     * Also placed directly in RAM because the CPU cannot read
     * initialization data from instruction ROM.
     */
    .data :
    {
        . = ALIGN(4);

        __data_start__ = .;
        *(.data*)
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM


    /*
     * Zero-initialized data.
     *
     * The startup code clears this.
     */
    .bss (NOLOAD) :
    {
        . = ALIGN(4);

        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM


    /*
     * Stack starts at the top of RAM and grows downward.
     */
    . = ORIGIN(RAM) + LENGTH(RAM);

    __StackTop = .;
    __stack_top = .;


    /*
     * Make these available to startup/debugging code.
     */
    __ram_start__ = ORIGIN(RAM);
    __ram_end__   = ORIGIN(RAM) + LENGTH(RAM);

    __rom_start__ = ORIGIN(ROM);
    __rom_end__   = ORIGIN(ROM) + LENGTH(ROM);


    /*
     * Make sure we didn't exceed either memory.
     */
    ASSERT(__StackTop >= __bss_end__,
           "RAM overflow: data/bss collide with stack")

    ASSERT(. <= ORIGIN(RAM) + LENGTH(RAM),
           "RAM overflow")

    ASSERT(SIZEOF(.text) <= LENGTH(ROM),
           "ROM overflow")
}