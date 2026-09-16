OUTPUT_FORMAT("elf32-littleriscv")

/* change this when we have a startup routine */
ENTRY(_start)

__ROM_BASE = 0x00000000;
__ROM_SIZE = 0x00001000;

__RAM_BASE = 0xC0000000;
__RAM_SIZE = 0x00001000;

/* __HEAP_BASE = 0x60000000;  */
/* __HEAP_SIZE = 0x8000000;   */

__STACK_SIZE = 0x00000100; 


MEMORY
{
  ROM   (rx)  : ORIGIN = __ROM_BASE, LENGTH = __ROM_SIZE
  RAM   (rwx) : ORIGIN = __RAM_BASE, LENGTH = __RAM_SIZE
  #  HEAP  (rwx) : ORIGIN = __HEAP_BASE, LENGTH = __HEAP_SIZE
}


SECTIONS
{

  /* The text section contains the vector table, all of our code and
      read-only data. Plus some data used by C++ and debugging tools to
      unwind the stack, some tables used by the startup code to copy
      initialized data from ROM to RAM and initialize the bss section,
      and the initialized data that must be copied.  All of this should
      be placed in ROM.  */

  .text :
  {
    . = 0;
    /* KEEP means ALWAYS include it, even if it is not referenced by
       any other code in the program
    */
    KEEP(*(.vectors)) /* Put the vector table first.              */
    KEEP(*(.init))    /* Then put the init code sections.         */
    KEEP(*(.fini))    /* Then put the fini code sections.         */
    *(.text*)         /* Then put all of the other text sections. */

    /* for C++, we will have constructors and destructors. */
    /* .ctors */
    /*    *crtbegin.o(.ctors)
          *crtbegin?.o(.ctors)
          *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
          *(SORT(.ctors.*))
          *(.ctors)
    */
    /* .dtors */
    /*    *crtbegin.o(.dtors)
          *crtbegin?.o(.dtors)
          *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
          *(SORT(.dtors.*))
          *(.dtors)
    */

    . = ALIGN(4);
    KEEP*(.rodata*)

    . = ALIGN(4);
    
    /* We may not need the eh_frame, data... something to check */
    KEEP(*(.eh_frame*))
    
  } > ROM


  /* Now we want to build a table that will be used to copy
     initialized static data from the ROM image to RAM during startup.
     Each entry in this table provides the starting and ending
     addresses (the ending address should no be copied) for the data
     that must be copied, and the target address where it must be
     copied to. This gives the pointers to the beginning and end of
     the data that must be copied, but not the actual data. */  
  .copy.table :
  {
    . = ALIGN(4);
    /* LONG (__etext) */        /* address of end of text section       */
    __copy_table_start__ = .;   /* set address of start of copy table   */
    /* first entry in copy table */
    LONG (__data_start__)       /* address of beginning of data section */
    LONG (__data_size__)        /* number of words to be moved */
    LONG (__data_target__)      /* target address for data section      */
    /* next entry in copy table */
    /* Add each additional data section here */
    /* LONG (__data2_start__) */
    /* LONG (__data2_size__)   */
    /* LONG (__data2_target__)  */ 
    __copy_table_end__ = .;     /* address of end of copy table   */
  } > ROM

  /* Now we want to build a table that will be used to initialize
     static variables to zero during startup. It is like the copy
     section, but just sets everything in the table to zero. */
  .zero.table :
  {
    . = ALIGN(4);
    __zero_table_start__ = .;
    LONG (__bss_start__)
    LONG (__bss_end__)
    /* Add each additional bss section here */
    /* LONG (__bss2_start__) */
    /* LONG ((__bss2_end__ - __bss2_start__) / 4) */
    __zero_table_end__ = .;
  } > ROM

  /* __etext is assumed by startup code to be word aligned,
     so make sure it is. */
  __etext = ALIGN (4);

  /* Initialized data must be copied from ROM to RAM before main() is
     called.  We can have the linker place a copy in ROM, and tell us
     where it is, so that our startup code can copy it from ROM to RAM
     before calling main(). */


 .data  : 
  {
     . =  ALIGN(4);

    /* __data_target__ is the address where the data section must be
       copied to before main() is called */
     __data_target__ = .;

    /* if we are using C++, we need vtable */
    /* *(vtable) */
    *(.data)
    . = ALIGN(4);
    *(.data.*)
    . = ALIGN(4);
    *(.sdata)
    . = ALIGN(4);
    *(.sdata.*)

    /* // if we are using C++, we need __preinit_array_start, etc
    /* // preinit data */
    /* . = ALIGN(4); */
    /* PROVIDE_HIDDEN (__preinit_array_start = .); */
    /* KEEP(*(.preinit_array)) */
    /* PROVIDE_HIDDEN (__preinit_array_end = .); */
    /* // init data */
    /* . = ALIGN(4); */
    /* PROVIDE_HIDDEN (__init_array_start = .); */
    /* KEEP(*(SORT(.init_array.*))) */
    /* KEEP(*(.init_array)) */
    /* PROVIDE_HIDDEN (__init_array_end = .); */
    /* // finit data */
    /* . = ALIGN(4); */
    /* PROVIDE_HIDDEN (__fini_array_start = .); */
    /* KEEP(*(SORT(.fini_array.*))) */
    /* KEEP(*(.fini_array)) */
    /* PROVIDE_HIDDEN (__fini_array_end = .); */

    /* // if using java, we need jcr
    /* KEEP(*(.jcr*)) */

    . = ALIGN(4);
    /* All data end */
    __data_target_end__ = .;
    . = ALIGN(4);

  } > RAM AT > ROM /* put data section in ROM, but address it for RAM */

  /* Calculate the size of the data section in words, so that the startup code
     can copy it from ROM to RAM. */
   __data_size__ = ( __data_target_end__ - __data_target__ ) / 4 ;
   /* get the address where the data section is in ROM */
   __data_start__ = LOADADDR( .data );


  /*
   * Secondary data section, optional
   *
   * Remember to add each additional data section
   * to the .copy.table above to asure proper
   * initialization during startup.
   */
  /*
  __etext2 = ALIGN (4);

  .data2 : AT (__etext2)
  {
    . = ALIGN(4);
    __data2_start__ = .;
    *(.data2)

    *(.data2.*)
    . = ALIGN(4);
    __data2_end__ = .;

  } > RAM2
  */

  .bss (COPY) :
  {
    . = ALIGN(4);
    __bss_start__ = .;
    *(.bss)
    . = ALIGN(4);
    *(.bss.*)
    . = ALIGN(4);
    *(.sbss)
    . = ALIGN(4);
    *(.sbss.*)
    . = ALIGN(4);
    *(COMMON)
    . = ALIGN(4);
    __bss_end__ = .;
  } > RAM

  /*
   * Secondary bss section, optional
   *
   * Remember to add each additional bss section
   * to the .zero.table above to asure proper
   * initialization during startup.
   */
  /*
  .bss2 :
  {
    . = ALIGN(4);
    __bss2_start__ = .;
    *(.bss2)
    *(.bss2.*)
    . = ALIGN(4);
    __bss2_end__ = .;
  } > RAM2 AT > RAM2
  */

  /* This heap setup probably will not work. */
  /* .heap (COPY) :  */
  /*   { */
  /*     . = ALIGN(8); */
  /*     __HeapBase = .; */
  /*     . = . + __HEAP_SIZE; */
  /*     __heap_size = __HEAP_SIZE; */
  /*     . = ALIGN(8); */
  /*     __HeapLimit = .; */
  /*     __HeapTop = .; */
  /*   } > HEAP */


  /* This heap setup may work */
  /*
  .heap (COPY) : 
  {
    . = ALIGN(8);
    __end__ = .;
    PROVIDE(end = .);
    __HeapBase = .;
    . = . + __HEAP_SIZE;
    __heap_size = __HEAP_SIZE;
    . = ALIGN(8);
    __HeapLimit = .;
    __HeapTop = .;
    __heap_size = __HEAP_SIZE;
  } > HEAP
  */
  /*  .stack ((ORIGIN(RAM) + LENGTH(RAM)) - __STACK_SIZE) (COPY) : */
  .stack ((ORIGIN(RAM) + LENGTH(RAM)) - __STACK_SIZE) :
  {
    . = ALIGN(8);
    __StackLimit = .;
    . = . + __STACK_SIZE;
    . = ALIGN(8);
    __StackTop = .;
    __stack_end__ = .;
      PROVIDE(__stack = __StackLimit);
  } > RAM

  /* Check if data + stack exceeds RAM limit */
  /* ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack") */

  /* Check if data + heap + stack exceeds RAM limit */
  /* ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack") */
}
