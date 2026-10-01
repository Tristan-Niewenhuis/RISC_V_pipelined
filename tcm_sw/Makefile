# Build programs for RISC_V_TCM: link with tcm.ld and start.S, then split
# the ELF into itcm.hex and dtcm.hex for tightly_coupled_memory.
#
#   make PROG=tcm_selftest      -> build/tcm_selftest.elf, build/itcm.hex,
#                                  build/dtcm.hex
#
# The core is RV32I with Zicsr/Zicntr: no M extension, so libgcc
# supplies multiply and divide.

CROSS  ?= riscv32-unknown-elf-
CC      = $(CROSS)gcc
OBJDUMP = $(CROSS)objdump
PROG   ?= tcm_selftest
BUILD   = build

CFLAGS  = -march=rv32i_zicsr_zicntr -mabi=ilp32 -O2 -ffreestanding \
          -fno-builtin -Wall -Wextra
LDFLAGS = -nostdlib -nostartfiles -T tcm.ld -Wl,--no-warn-rwx-segments

all: $(BUILD)/itcm.hex

$(BUILD)/$(PROG).elf: start.S $(PROG).c tcm.ld | $(BUILD)
	$(CC) $(CFLAGS) $(LDFLAGS) start.S $(PROG).c -lgcc -o $@
	$(OBJDUMP) -d $@ > $(BUILD)/$(PROG).dis

$(BUILD)/itcm.hex: $(BUILD)/$(PROG).elf elf2tcm.py
	./elf2tcm.py $< $(BUILD)

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)

.PHONY: all clean
