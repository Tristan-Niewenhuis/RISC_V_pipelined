        .section .init
  
        .func _start
        .global _start
_start:
        // Set the stack pointer to value given by linker script
        la      sp,__StackTop

        // clear the bss section
	la      t0,__bss_start__ // get address where .bss starts
        la      t1,__bss_end__   // get address where .bss ends
	blt	t0,t1,movedata   // if there is no .bss, skip the loop
        mv      t3,zero
bssloop:sw      t3,(t0)
	addi	t0,t0,4
        blt     t0,t1,bssloop

        // copy initialized data from ROM to RAM
movedata:	
        la     t0,__copy_table_start__  
        la     t1,__copy_table_end__
copyloop:
        bge     t0,t1,endcopy // exit if not more entries in the table
        lw      t2,(t0)       // get start address of next chunk
	addi    t0,t0,4
        lw      t3,(t0)       // get end address of next chunk
	addi    t0,t0,4
        lw      t4,(t0)       // get target address of next chunk
	addi    t0,t0,4

ctloop: lw      t5,(t2)      // load word from this chunk
	addi    t2,t2,4
        sw      t5,(t4)      // store word from this chunk to the target addr
	addi    t4,t4,4
        addi    t3,t3,-1     // subtract 
        bgtz    t3,ctloop    // if not done, keep going.
        j       copyloop     // top of loop checks to see if we are done.
endcopy:

        jal   main
hang:   j     hang
