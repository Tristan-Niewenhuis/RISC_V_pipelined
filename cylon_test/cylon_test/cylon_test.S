
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
  44:	f9010113          	addi	x2,x2,-112
  48:	06112623          	sw	x1,108(x2)
  4c:	06812423          	sw	x8,104(x2)
  50:	07212223          	sw	x18,100(x2)
  54:	07312023          	sw	x19,96(x2)
  58:	05412e23          	sw	x20,92(x2)
  5c:	05512c23          	sw	x21,88(x2)
  60:	05612a23          	sw	x22,84(x2)
  64:	05712823          	sw	x23,80(x2)
  68:	05812623          	sw	x24,76(x2)
  6c:	05912423          	sw	x25,72(x2)
  70:	05a12223          	sw	x26,68(x2)
  74:	05b12023          	sw	x27,64(x2)
  78:	07010413          	addi	x8,x2,112
  7c:	00100793          	addi	x15,x0,1
  80:	fcf42623          	sw	x15,-52(x8)

00000084 <.L9>:
  84:	c0002773          	csrrs	x14,cycle,x0
  88:	000007b7          	lui	x15,0x0
  8c:	00e7a023          	sw	x14,0(x15) # 0 <delay>
  90:	c8002773          	csrrs	x14,cycleh,x0
  94:	000007b7          	lui	x15,0x0
  98:	00e7a023          	sw	x14,0(x15) # 0 <delay>
  9c:	400107b7          	lui	x15,0x40010
  a0:	0007a783          	lw	x15,0(x15) # 40010000 <.L7+0x4000fefc>
  a4:	fcf42423          	sw	x15,-56(x8)
  a8:	0280006f          	jal	x0,d0 <.L5>

000000ac <.L6>:
  ac:	400007b7          	lui	x15,0x40000
  b0:	fcc42703          	lw	x14,-52(x8)
  b4:	00e7a023          	sw	x14,0(x15) # 40000000 <.L7+0x3ffffefc>
  b8:	fcc42783          	lw	x15,-52(x8)
  bc:	00179793          	slli	x15,x15,0x1
  c0:	fcf42623          	sw	x15,-52(x8)
  c4:	fc842503          	lw	x10,-56(x8)
  c8:	00000097          	auipc	x1,0x0
  cc:	000080e7          	jalr	x1,0(x1) # c8 <.L6+0x1c>

000000d0 <.L5>:
  d0:	fcc42703          	lw	x14,-52(x8)
  d4:	000087b7          	lui	x15,0x8
  d8:	fcf71ae3          	bne	x14,x15,ac <.L6>
  dc:	0280006f          	jal	x0,104 <.L7>

000000e0 <.L8>:
  e0:	400007b7          	lui	x15,0x40000
  e4:	fcc42703          	lw	x14,-52(x8)
  e8:	00e7a023          	sw	x14,0(x15) # 40000000 <.L7+0x3ffffefc>
  ec:	fcc42783          	lw	x15,-52(x8)
  f0:	0017d793          	srli	x15,x15,0x1
  f4:	fcf42623          	sw	x15,-52(x8)
  f8:	fc842503          	lw	x10,-56(x8)
  fc:	00000097          	auipc	x1,0x0
 100:	000080e7          	jalr	x1,0(x1) # fc <.L8+0x1c>

00000104 <.L7>:
 104:	fcc42703          	lw	x14,-52(x8)
 108:	00100793          	addi	x15,x0,1
 10c:	fcf71ae3          	bne	x14,x15,e0 <.L8>
 110:	c0002773          	csrrs	x14,cycle,x0
 114:	000007b7          	lui	x15,0x0
 118:	00e7a023          	sw	x14,0(x15) # 0 <delay>
 11c:	c8002773          	csrrs	x14,cycleh,x0
 120:	000007b7          	lui	x15,0x0
 124:	00e7a023          	sw	x14,0(x15) # 0 <delay>
 128:	000007b7          	lui	x15,0x0
 12c:	0007a783          	lw	x15,0(x15) # 0 <delay>
 130:	faf42423          	sw	x15,-88(x8)
 134:	fa042623          	sw	x0,-84(x8)
 138:	fa842783          	lw	x15,-88(x8)
 13c:	00079c93          	slli	x25,x15,0x0
 140:	00000c13          	addi	x24,x0,0
 144:	000007b7          	lui	x15,0x0
 148:	0007a783          	lw	x15,0(x15) # 0 <delay>
 14c:	faf42023          	sw	x15,-96(x8)
 150:	fa042223          	sw	x0,-92(x8)
 154:	fa042683          	lw	x13,-96(x8)
 158:	fa442703          	lw	x14,-92(x8)
 15c:	00068793          	addi	x15,x13,0
 160:	00fc6933          	or	x18,x24,x15
 164:	00070793          	addi	x15,x14,0
 168:	00fce9b3          	or	x19,x25,x15
 16c:	000007b7          	lui	x15,0x0
 170:	0007a783          	lw	x15,0(x15) # 0 <delay>
 174:	f8f42c23          	sw	x15,-104(x8)
 178:	f8042e23          	sw	x0,-100(x8)
 17c:	f9842783          	lw	x15,-104(x8)
 180:	00079b93          	slli	x23,x15,0x0
 184:	00000b13          	addi	x22,x0,0
 188:	000007b7          	lui	x15,0x0
 18c:	0007a783          	lw	x15,0(x15) # 0 <delay>
 190:	00078d13          	addi	x26,x15,0
 194:	00000d93          	addi	x27,x0,0
 198:	01ab6a33          	or	x20,x22,x26
 19c:	01bbeab3          	or	x21,x23,x27
 1a0:	41490733          	sub	x14,x18,x20
 1a4:	00070693          	addi	x13,x14,0
 1a8:	00d936b3          	sltu	x13,x18,x13
 1ac:	415987b3          	sub	x15,x19,x21
 1b0:	40d786b3          	sub	x13,x15,x13
 1b4:	00068793          	addi	x15,x13,0
 1b8:	fce42023          	sw	x14,-64(x8)
 1bc:	fcf42223          	sw	x15,-60(x8)
 1c0:	fc042783          	lw	x15,-64(x8)
 1c4:	faf42e23          	sw	x15,-68(x8)
 1c8:	fc442783          	lw	x15,-60(x8)
 1cc:	0007d793          	srli	x15,x15,0x0
 1d0:	f8f42823          	sw	x15,-112(x8)
 1d4:	f8042a23          	sw	x0,-108(x8)
 1d8:	f9042783          	lw	x15,-112(x8)
 1dc:	faf42c23          	sw	x15,-72(x8)
 1e0:	fbc42783          	lw	x15,-68(x8)
 1e4:	00078513          	addi	x10,x15,0
 1e8:	fb842783          	lw	x15,-72(x8)
 1ec:	00078593          	addi	x11,x15,0
 1f0:	12345637          	lui	x12,0x12345
 1f4:	67860613          	addi	x12,x12,1656 # 12345678 <.L7+0x12345574>
 1f8:	e8dff06f          	jal	x0,84 <.L9>
