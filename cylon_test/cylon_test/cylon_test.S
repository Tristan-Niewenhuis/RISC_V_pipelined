
cylon_test.o:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <delay>:
   0:	fd010113          	addi	x2,x2,-48
   4:	02812623          	sw	x8,44(x2)
   8:	03010413          	addi	x8,x2,48
   c:	fca42e23          	sw	x10,-36(x8)
  10:	fe042623          	sw	x0,-20(x8)
  14:	0100006f          	jal	x0,24 <.L2>

00000018 <.L3>:
  18:	fec42783          	lw	x15,-20(x8)
  1c:	00178793          	addi	x15,x15,1
  20:	fef42623          	sw	x15,-20(x8)

00000024 <.L2>:
  24:	fec42703          	lw	x14,-20(x8)
  28:	fdc42783          	lw	x15,-36(x8)
  2c:	fef766e3          	bltu	x14,x15,18 <.L3>
  30:	00000013          	addi	x0,x0,0
  34:	00000013          	addi	x0,x0,0
  38:	02c12403          	lw	x8,44(x2)
  3c:	03010113          	addi	x2,x2,48
  40:	00008067          	jalr	x0,0(x1)

00000044 <main>:
  44:	fe010113          	addi	x2,x2,-32
  48:	00112e23          	sw	x1,28(x2)
  4c:	00812c23          	sw	x8,24(x2)
  50:	02010413          	addi	x8,x2,32
  54:	00100793          	addi	x15,x0,1
  58:	fef42623          	sw	x15,-20(x8)

0000005c <.L9>:
  5c:	400107b7          	lui	x15,0x40010
  60:	0007a783          	lw	x15,0(x15) # 40010000 <.L7+0x4000ff3c>
  64:	fef42423          	sw	x15,-24(x8)
  68:	0280006f          	jal	x0,90 <.L5>

0000006c <.L6>:
  6c:	400007b7          	lui	x15,0x40000
  70:	fec42703          	lw	x14,-20(x8)
  74:	00e7a023          	sw	x14,0(x15) # 40000000 <.L7+0x3fffff3c>
  78:	fec42783          	lw	x15,-20(x8)
  7c:	00179793          	slli	x15,x15,0x1
  80:	fef42623          	sw	x15,-20(x8)
  84:	fe842503          	lw	x10,-24(x8)
  88:	00000097          	auipc	x1,0x0
  8c:	000080e7          	jalr	x1,0(x1) # 88 <.L6+0x1c>

00000090 <.L5>:
  90:	fec42703          	lw	x14,-20(x8)
  94:	000087b7          	lui	x15,0x8
  98:	fcf71ae3          	bne	x14,x15,6c <.L6>
  9c:	0280006f          	jal	x0,c4 <.L7>

000000a0 <.L8>:
  a0:	400007b7          	lui	x15,0x40000
  a4:	fec42703          	lw	x14,-20(x8)
  a8:	00e7a023          	sw	x14,0(x15) # 40000000 <.L7+0x3fffff3c>
  ac:	fec42783          	lw	x15,-20(x8)
  b0:	0017d793          	srli	x15,x15,0x1
  b4:	fef42623          	sw	x15,-20(x8)
  b8:	fe842503          	lw	x10,-24(x8)
  bc:	00000097          	auipc	x1,0x0
  c0:	000080e7          	jalr	x1,0(x1) # bc <.L8+0x1c>

000000c4 <.L7>:
  c4:	fec42703          	lw	x14,-20(x8)
  c8:	00100793          	addi	x15,x0,1
  cc:	fcf71ae3          	bne	x14,x15,a0 <.L8>
  d0:	f8dff06f          	jal	x0,5c <.L9>
