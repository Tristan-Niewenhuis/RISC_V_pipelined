#!/usr/bin/env python3
"""Generate the ITCM and DTCM init images for riscv_tcm_tb.

The program is the 37-check instruction regression from riscv_core_tb
(RISC_V_AXI), retargeted to the RISC_V_TCM memory map: x31 holds the
DTCM base 0x10000000, and one extra check loads ITCM word 0 through the
data lane.  The block from 0x1CC exercises the AXI4-Lite peripheral
port (x30 = 0x40000000): stores and loads that stall MEM, combined with
load-use hazards, byte lanes, a DTCM store in EX during a peripheral
load, and a jump after a peripheral store.  Edit PROGRAM here and rerun; do not edit the .hex files.
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))

# (byte address, encoding)  # assembly
PROGRAM = [
    (0x0000, 0x10000FB7),  # lui   x31, 0x10000        ; x31 = 0x10000000 (DTCM base)
    (0x0004, 0x0F000093),  # addi  x1, x0, 0xF0
    (0x0008, 0x00400113),  # addi  x2, x0, 4
    (0x000c, 0x80000293),  # addi  x5, x0, -2048
    (0x0010, 0x002091B3),  # sll   x3, x1, x2
    (0x0014, 0x0020D233),  # srl   x4, x1, x2
    (0x0018, 0x4022D333),  # sra   x6, x5, x2
    (0x001c, 0x0022D3B3),  # srl   x7, x5, x2
    (0x0020, 0x00409413),  # slli  x8, x1, 4
    (0x0024, 0x0042D493),  # srli  x9, x5, 4
    (0x0028, 0x4042D513),  # srai  x10, x5, 4
    (0x002c, 0x0012A5B3),  # slt   x11, x5, x1
    (0x0030, 0x0012B633),  # sltu  x12, x5, x1
    (0x0034, 0x00102693),  # slti  x13, x0, 1
    (0x0038, 0xFFF03713),  # sltiu x14, x0, -1
    (0x003c, 0x0020C7B3),  # xor   x15, x1, x2
    (0x0040, 0x0020E833),  # or    x16, x1, x2
    (0x0044, 0x0020F8B3),  # and   x17, x1, x2
    (0x0048, 0x0FF0C913),  # xori  x18, x1, 0xFF
    (0x004c, 0x0FF0E993),  # ori   x19, x1, 0xFF
    (0x0050, 0x0FF0FA13),  # andi  x20, x1, 0xFF
    (0x0054, 0x00208AB3),  # add   x21, x1, x2
    (0x0058, 0x40208B33),  # sub   x22, x1, x2
    (0x005c, 0x003FA023),  # sw    x3 , 0x00(x31)
    (0x0060, 0x004FA223),  # sw    x4 , 0x04(x31)
    (0x0064, 0x005FA423),  # sw    x5 , 0x08(x31)
    (0x0068, 0x006FA623),  # sw    x6 , 0x0C(x31)
    (0x006c, 0x007FA823),  # sw    x7 , 0x10(x31)
    (0x0070, 0x008FAA23),  # sw    x8 , 0x14(x31)
    (0x0074, 0x009FAC23),  # sw    x9 , 0x18(x31)
    (0x0078, 0x00AFAE23),  # sw    x10, 0x1C(x31)
    (0x007c, 0x02BFA023),  # sw    x11, 0x20(x31)
    (0x0080, 0x02CFA223),  # sw    x12, 0x24(x31)
    (0x0084, 0x02DFA423),  # sw    x13, 0x28(x31)
    (0x0088, 0x02EFA623),  # sw    x14, 0x2C(x31)
    (0x008c, 0x02FFA823),  # sw    x15, 0x30(x31)
    (0x0090, 0x030FAA23),  # sw    x16, 0x34(x31)
    (0x0094, 0x031FAC23),  # sw    x17, 0x38(x31)
    (0x0098, 0x032FAE23),  # sw    x18, 0x3C(x31)
    (0x009c, 0x053FA023),  # sw    x19, 0x40(x31)
    (0x00a0, 0x054FA223),  # sw    x20, 0x44(x31)
    (0x00a4, 0x055FA423),  # sw    x21, 0x48(x31)
    (0x00a8, 0x056FA623),  # sw    x22, 0x4C(x31)
    (0x00ac, 0x00000B97),  # auipc x23, 0              ; result must equal this PC
    (0x00b0, 0x057FA823),  # sw    x23, 0x50(x31)
    (0x00b4, 0x00800C6F),  # jal   x24, +8             ; link = PC+4, skips next
    (0x00b8, 0x0EE00C93),  # addi  x25, x0, 0xEE       ; MUST BE SKIPPED
    (0x00bc, 0x058FAA23),  # sw    x24, 0x54(x31)
    (0x00c0, 0x059FAC23),  # sw    x25, 0x58(x31)
    (0x00c4, 0x0F000D93),  # addi  x27, x0, 0xF0       ; jalr target
    (0x00c8, 0x000D8E67),  # jalr  x28, 0(x27)         ; -> 0xF0, link = PC+4
    (0x00cc, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00d0, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00d4, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00d8, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00dc, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00e0, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00e4, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00e8, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00ec, 0x09900C93),  # addi  x25, x0, 0x99       ; MUST BE SKIPPED (jalr pad)
    (0x00f0, 0x05CFAE23),  # sw    x28, 0x5C(x31)      ; <- jalr lands here (0xF0)
    (0x00f4, 0x100FAE83),  # lw    x29, 0x100(x31)     ; 0x81726354
    (0x00f8, 0x07DFA023),  # sw    x29, 0x60(x31)
    (0x00fc, 0x100F8083),  # lb  +0    x1, 0x100(x31)
    (0x0100, 0x061FA223),  # sw    x1, 0x64(x31)
    (0x0104, 0x101F8083),  # lb  +1    x1, 0x101(x31)
    (0x0108, 0x061FA423),  # sw    x1, 0x68(x31)
    (0x010c, 0x102F8083),  # lb  +2    x1, 0x102(x31)
    (0x0110, 0x061FA623),  # sw    x1, 0x6C(x31)
    (0x0114, 0x103F8083),  # lb  +3    x1, 0x103(x31)
    (0x0118, 0x061FA823),  # sw    x1, 0x70(x31)
    (0x011c, 0x103FC083),  # lbu +3    x1, 0x103(x31)
    (0x0120, 0x061FAA23),  # sw    x1, 0x74(x31)
    (0x0124, 0x100F9083),  # lh  +0    x1, 0x100(x31)
    (0x0128, 0x061FAC23),  # sw    x1, 0x78(x31)
    (0x012c, 0x102F9083),  # lh  +2    x1, 0x102(x31)
    (0x0130, 0x061FAE23),  # sw    x1, 0x7C(x31)
    (0x0134, 0x102FD083),  # lhu +2    x1, 0x102(x31)
    (0x0138, 0x081FA023),  # sw    x1, 0x80(x31)
    (0x013c, 0x0AA00113),  # addi  x2, x0, 0xAA
    (0x0140, 0x102F8823),  # sb    x2, 0x110(x31)     ; byte offset 0
    (0x0144, 0x102F88A3),  # sb    x2, 0x111(x31)     ; byte offset 1
    (0x0148, 0x102F8923),  # sb    x2, 0x112(x31)     ; byte offset 2
    (0x014c, 0x102F89A3),  # sb    x2, 0x113(x31)     ; byte offset 3
    (0x0150, 0x110FA083),  # lw    x1, 0x110(x31)      ; expect AAAAAAAA
    (0x0154, 0x081FA223),  # sw    x1, 0x84(x31)
    (0x0158, 0x0AB00113),  # addi  x2, x0, 0xAB
    (0x015c, 0x102F9A23),  # sh    x2, 0x114(x31)      ; halfword offset 0
    (0x0160, 0x102F9B23),  # sh    x2, 0x116(x31)      ; halfword offset 2
    (0x0164, 0x114FA083),  # lw    x1, 0x114(x31)      ; expect 00AB00AB
    (0x0168, 0x081FA423),  # sw    x1, 0x88(x31)
    (0x016c, 0x00000293),  # addi  x5, x0, 0           ; sum = 0
    (0x0170, 0x00500313),  # addi  x6, x0, 5           ; i = 5
    (0x0174, 0x006282B3),  # add   x5, x5, x6          ; loop:
    (0x0178, 0xFFF30313),  # addi  x6, x6, -1
    (0x017c, 0xFE031CE3),  # bne   x6, x0, loop        ; backward branch
    (0x0180, 0x085FA623),  # sw    x5, 0x8C(x31)       ; expect 15
    (0x0184, 0x00300093),  # addi  x1, x0, 3
    (0x0188, 0xFFD00113),  # addi  x2, x0, -3
    (0x018c, 0x00000393),  # addi  x7, x0, 0           ; counts branches NOT taken
    (0x0190, 0x00108463),  # beq  x1,x1 +8          ; must be TAKEN
    (0x0194, 0x00138393),  # addi  x7, x7, 1           ; skipped if taken
    (0x0198, 0x00209463),  # bne  x1,x2 +8          ; must be TAKEN
    (0x019c, 0x00138393),  # addi  x7, x7, 1           ; skipped if taken
    (0x01a0, 0x00114463),  # blt  x2,x1 +8          ; must be TAKEN
    (0x01a4, 0x00138393),  # addi  x7, x7, 1           ; skipped if taken
    (0x01a8, 0x0020D463),  # bge  x1,x2 +8          ; must be TAKEN
    (0x01ac, 0x00138393),  # addi  x7, x7, 1           ; skipped if taken
    (0x01b0, 0x0020E463),  # bltu x1,x2 +8          ; must be TAKEN
    (0x01b4, 0x00138393),  # addi  x7, x7, 1           ; skipped if taken
    (0x01b8, 0x00117463),  # bgeu x2,x1 +8          ; must be TAKEN
    (0x01bc, 0x00138393),  # addi  x7, x7, 1           ; skipped if taken
    (0x01c0, 0x087FA823),  # sw    x7, 0x90(x31)       ; expect 0
    (0x01c4, 0x00002083),  # lw    x1, 0(x0)           ; ITCM word 0 via the data lane
    (0x01c8, 0x081FAA23),  # sw    x1, 0x94(x31)       ; expect 10000FB7
    (0x01cc, 0x40000F37),  # lui x30, 0x40000  ; x30 = 0x40000000 (peripheral base)
    (0x01d0, 0x05A00093),  # addi x1, x0, 0x5A
    (0x01d4, 0x001F2023),  # sw x1, 0(x30)  ; peripheral store
    (0x01d8, 0x000F2103),  # lw x2, 0(x30)  ; peripheral load, used next
    (0x01dc, 0x082FAC23),  # sw x2, 0x98(x31)  ; expect 0000005A
    (0x01e0, 0x001F03A3),  # sb x1, 7(x30)  ; byte lane 3 of word 4
    (0x01e4, 0x007F4183),  # lbu x3, 7(x30)
    (0x01e8, 0x083FAE23),  # sw x3, 0x9C(x31)  ; expect 0000005A
    (0x01ec, 0x000F2203),  # lw x4, 0(x30)
    (0x01f0, 0x00120213),  # addi x4, x4, 1
    (0x01f4, 0x004F2423),  # sw x4, 8(x30)
    (0x01f8, 0x008F2283),  # lw x5, 8(x30)
    (0x01fc, 0x0A5FA023),  # sw x5, 0xA0(x31)  ; expect 0000005B
    (0x0200, 0x000F2383),  # lw x7, 0(x30)  ; peripheral load in MEM ...
    (0x0204, 0x0A1FA223),  # sw x1, 0xA4(x31)  ; ... while this DTCM store is in EX; expect 0000005A
    (0x0208, 0x0A7FA423),  # sw x7, 0xA8(x31)  ; expect 0000005A
    (0x020c, 0x00000493),  # addi x9, x0, 0
    (0x0210, 0x001F2623),  # sw x1, 12(x30)  ; peripheral store, then a jump
    (0x0214, 0x0080046F),  # jal x8, 1f  ; link = this pc + 4
    (0x0218, 0x07700493),  # addi x9, x0, 0x77  ; must be skipped
    (0x021c, 0x0A8FA623),  # sw x8, 0xAC(x31)  ; expect link
    (0x0220, 0x0A9FA823),  # sw x9, 0xB0(x31)  ; expect 00000000
    (0x0224, 0x004F2503),  # lw x10, 4(x30)  ; sb at offset 7 left word 4 = 5A000000
    (0x0228, 0x0AAFAA23),  # sw x10, 0xB4(x31)  ; expect 5A000000
    (0x022c, 0x0000006F),  # jal x0, 2b  ; spin
]

# DTCM preload: (byte offset from the DTCM base, word).  The byte and
# halfword load tests read offset 0x100.
DTCM_DATA = [
    (0x100, 0x81726354),
]


def write_hex(name, words):
    with open(os.path.join(HERE, name), "w") as f:
        for w in words:
            f.write(f"{w:08X}\n")


itcm = []
for addr, word in PROGRAM:
    assert addr == 4 * len(itcm), f"gap or overlap at {addr:#x}"
    itcm.append(word)

dtcm = [0] * (max(off for off, _ in DTCM_DATA) // 4 + 1)
for off, word in DTCM_DATA:
    dtcm[off // 4] = word

write_hex("itcm.hex", itcm)
write_hex("dtcm.hex", dtcm)
print(f"itcm.hex: {len(itcm)} words, dtcm.hex: {len(dtcm)} words")
