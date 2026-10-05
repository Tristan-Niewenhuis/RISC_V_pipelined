#!/usr/bin/env python3
"""Convert a RISC_V_TCM ELF into itcm.hex and dtcm.hex.

Usage: elf2tcm.py program.elf [outdir]

Each output has one 32-bit word per line, as tightly_coupled_memory's
.hex init format expects.  The ITCM image holds every loadable segment
at 0x00000000 (code and read-only data); the DTCM image holds every
loadable segment at 0x10000000 (.data).  .bss is NOLOAD and start.S
clears it.

The ELF is read directly from its program headers, so no toolchain is
needed to run this script.
"""
import os
import struct
import sys

REGIONS = {"itcm.hex": (0x00000000, 64 * 1024),
           "dtcm.hex": (0x10000000, 64 * 1024)}
PT_LOAD = 1


def load_segments(raw):
    """Yield (vaddr, bytes) for each PT_LOAD segment of a 32-bit ELF."""
    if raw[:4] != b"\x7fELF" or raw[4] != 1 or raw[5] != 1:
        sys.exit("elf2tcm: not a 32-bit little-endian ELF")
    phoff, = struct.unpack_from("<I", raw, 28)
    phentsize, phnum = struct.unpack_from("<HH", raw, 42)
    for i in range(phnum):
        p_type, p_offset, p_vaddr, _, p_filesz = struct.unpack_from(
            "<IIIII", raw, phoff + i * phentsize)
        if p_type == PT_LOAD and p_filesz > 0:
            yield p_vaddr, raw[p_offset:p_offset + p_filesz]


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    elf = sys.argv[1]
    outdir = sys.argv[2] if len(sys.argv) > 2 else "."
    with open(elf, "rb") as f:
        raw = f.read()
    segments = list(load_segments(raw))
    for name, (base, size) in REGIONS.items():
        image = bytearray()
        for vaddr, data in segments:
            if base <= vaddr < base + size:
                start = vaddr - base
                if start + len(data) > size:
                    sys.exit(f"elf2tcm: segment at {vaddr:#x} overflows {name}")
                if len(image) < start + len(data):
                    image.extend(b"\0" * (start + len(data) - len(image)))
                image[start:start + len(data)] = data
        with open(os.path.join(outdir, name), "w") as f:
            for i in range(0, len(image), 4):
                word = int.from_bytes(image[i:i + 4].ljust(4, b"\0"), "little")
                f.write(f"{word:08X}\n")
        print(f"{name}: {(len(image) + 3) // 4} words")


if __name__ == "__main__":
    main()
