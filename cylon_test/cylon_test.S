	.file	"cylon_test.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	delay
	.type	delay, @function
delay:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	j	.L2
.L3:
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	lw	a5,-36(s0)
	bltu	a4,a5,.L3
	nop
	nop
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	delay, .-delay
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,1
	sw	a5,-20(s0)
.L9:
	li	a5,1073807360
	lw	a5,0(a5)
	sw	a5,-24(s0)
	j	.L5
.L6:
	li	a5,1073741824
	lw	a4,-20(s0)
	sw	a4,0(a5)
	lw	a5,-20(s0)
	slli	a5,a5,1
	sw	a5,-20(s0)
	lw	a0,-24(s0)
	call	delay
.L5:
	lw	a4,-20(s0)
	li	a5,32768
	bne	a4,a5,.L6
	j	.L7
.L8:
	li	a5,1073741824
	lw	a4,-20(s0)
	sw	a4,0(a5)
	lw	a5,-20(s0)
	srli	a5,a5,1
	sw	a5,-20(s0)
	lw	a0,-24(s0)
	call	delay
.L7:
	lw	a4,-20(s0)
	li	a5,1
	bne	a4,a5,.L8
	j	.L9
	.size	main, .-main
	.ident	"GCC: (GNU) 13.3.0"
