# =============================================================================
# Makefile -- RV32I pipeline/forwarding torture test
#   make            -> build/pipeline_test.elf, rom.coe, ram.coe, .lst, tests.txt
#   make clean
#
# Toolchain prefix is auto-detected (riscv32-unknown-elf-, riscv64-unknown-elf-,
# riscv-none-elf-, ...).  Force one with:  make CROSS=riscv64-unknown-elf-
#
# Options (all optional):
#   make GAP_NOPS=0 CHECK_NOPS=0     back-to-back stress (no isolating nops)
#   make TEST_CSR=1                  + instret / cycle counter tests
#   make TEST_CSR_RW=1               + CSR (mscratch) read-after-write hazards
#   make NO_LONG_JUMP=1              drop the ~6 KB long-JAL nop block
#   make NO_JALR_LSB_TEST=1          drop the final "jalr clears bit 0" test
#   make ROM_DEPTH=16384 RAM_DEPTH=16384   pad .coe files to the BRAM depth in
#                                    WORDS (default: no padding; Vivado zero-
#                                    fills the rest of the memory itself)
# Needs GNU make, od and awk (Linux / WSL / MSYS2).
# =============================================================================

TARGET   := pipeline_test
SRC      := pipeline_test.S
LDSCRIPT := link.ld
BUILD    := build

ARCH     ?= rv32i_zicsr_zicntr
ABI      ?= ilp32

# ---- toolchain auto-detect --------------------------------------------------
CROSS ?= $(firstword $(foreach p,riscv32-unknown-elf- riscv64-unknown-elf- riscv-none-elf- riscv-unknown-elf- riscv64-elf- riscv32-elf-,$(if $(shell command -v $(p)gcc 2>/dev/null),$(p))))
ifeq ($(CROSS),)
CROSS := riscv64-unknown-elf-
endif
CC      := $(CROSS)gcc
OBJCOPY := $(CROSS)objcopy
OBJDUMP := $(CROSS)objdump
NM      := $(CROSS)nm
SIZE    := $(CROSS)size

# ---- build-time options -> -D flags ----------------------------------------
DEFS :=
ifneq ($(GAP_NOPS),)
DEFS += -DGAP_NOPS=$(GAP_NOPS)
endif
ifneq ($(CHECK_NOPS),)
DEFS += -DCHECK_NOPS=$(CHECK_NOPS)
endif
ifeq ($(TEST_CSR),1)
DEFS += -DTEST_CSR
endif
ifeq ($(TEST_CSR_RW),1)
DEFS += -DTEST_CSR_RW
endif
ifeq ($(NO_LONG_JUMP),1)
DEFS += -DNO_LONG_JUMP
endif
ifeq ($(NO_JALR_LSB_TEST),1)
DEFS += -DNO_JALR_LSB_TEST
endif

# -mno-relax: keep every instruction exactly where the source put it (the
# tests depend on exact instruction distances)
ASFLAGS  := -march=$(ARCH) -mabi=$(ABI) -mno-relax $(DEFS)
LDFLAGS  := -march=$(ARCH) -mabi=$(ABI) -mno-relax -nostdlib -nostartfiles -static \
            -Wl,--gc-sections -Wl,--no-warn-rwx-segments -Wl,--build-id=none \
            -Wl,-Map=$(BUILD)/$(TARGET).map -T $(LDSCRIPT)

ROM_DEPTH ?= 0
RAM_DEPTH ?= 0
ROM_ORIGIN ?= 0x00001000
ROM_ORIGIN_BYTES := $(shell printf '%d' $(ROM_ORIGIN))

ELF := $(BUILD)/$(TARGET).elf
OBJ := $(BUILD)/$(TARGET).o

.PHONY: all clean coe tests lst info FORCE
all: $(ELF) coe lst tests info

# rebuild when the -D options change
$(BUILD)/flags.stamp: FORCE | $(BUILD)
	@echo '$(ASFLAGS) $(LDFLAGS) ROM_ORIGIN=$(ROM_ORIGIN)' | cmp -s - $@ || echo '$(ASFLAGS) $(LDFLAGS) ROM_ORIGIN=$(ROM_ORIGIN)' > $@

$(BUILD):
	@mkdir -p $@

$(OBJ): $(SRC) $(BUILD)/flags.stamp | $(BUILD)
	$(CC) $(ASFLAGS) -c $< -o $@

$(ELF): $(OBJ) $(LDSCRIPT) $(BUILD)/flags.stamp
	$(CC) $(LDFLAGS) -o $@ $(OBJ)
	@$(SIZE) $@ 2>/dev/null || true

# ---- raw binaries ------------------------------------------------------------
# ROM = zero padding up to ROM_ORIGIN, followed by the linked .text bytes.
# This makes the byte offset in rom.bin match the code's linked ROM address.
$(BUILD)/rom.bin: $(ELF) $(BUILD)/flags.stamp Makefile
	$(OBJCOPY) -O binary -j .text $< $(BUILD)/rom.text.bin
	dd if=/dev/zero of=$@ bs=1 count=$(ROM_ORIGIN_BYTES) status=none
	cat $(BUILD)/rom.text.bin >> $@
# RAM image = .mailbox + .rodata + .data (starts at 0x00010000; .bss is NOLOAD)
$(BUILD)/ram.bin: $(ELF)
	$(OBJCOPY) -O binary -j .mailbox -j .rodata -j .data --gap-fill 0 $< $@

# ---- Vivado .coe (32-bit words, hex, little-endian byte order = RV32) ----------
define AWK_COE
{ w[NR] = $$1 }
END {
  n = (depth > NR) ? depth : NR
  print "memory_initialization_radix=16;"
  print "memory_initialization_vector="
  for (i = 1; i <= n; i++)
    printf "%s%s\n", (i <= NR ? w[i] : "00000000"), (i < n ? "," : ";")
}
endef
export AWK_COE

$(BUILD)/rom.coe: DEPTH := $(ROM_DEPTH)
$(BUILD)/ram.coe: DEPTH := $(RAM_DEPTH)
# rom.coe is generated from the padded rom.bin, so its first ROM_ORIGIN/4
# words are zero and .text begins at its linked word address.
$(BUILD)/rom.coe: $(BUILD)/flags.stamp Makefile
$(BUILD)/%.coe: $(BUILD)/%.bin
	od -An -v -w4 -tx4 $< | awk -v depth=$(DEPTH) "$$AWK_COE" > $@

coe: $(BUILD)/rom.coe $(BUILD)/ram.coe

# ---- listing with addresses (match PCs in the waveform against this) ----------
lst: $(BUILD)/$(TARGET).lst
$(BUILD)/$(TARGET).lst: $(ELF)
	$(OBJDUMP) -d -M numeric $< > $@

# ---- test ID -> start PC -> name  (ID is what you see in x28 / t3) -------------
tests: $(BUILD)/tests.txt
$(BUILD)/tests.txt: $(ELF)
	@echo "ID  PC          name" > $@
	@$(NM) -n $< | awk '$$3 ~ /^T_/ { n++; printf "%-3d 0x%s  %s\n", n, $$1, substr($$3,3) }' >> $@

info: $(BUILD)/rom.bin $(BUILD)/ram.bin $(BUILD)/tests.txt
	@echo "ROM image : $$(wc -c < $(BUILD)/rom.bin) bytes ($$(( $$(wc -c < $(BUILD)/rom.bin) / 4 )) words)  -> $(BUILD)/rom.coe"
	@echo "RAM image : $$(wc -c < $(BUILD)/ram.bin) bytes ($$(( $$(wc -c < $(BUILD)/ram.bin) / 4 )) words)  -> $(BUILD)/ram.coe"
	@echo "Tests     : $$(( $$(wc -l < $(BUILD)/tests.txt) - 1 ))  (see $(BUILD)/tests.txt)"
	@echo "Mailbox   : 0x00010000 (status/id/expected/actual/PC)   x31: 0x600D600D=PASS 0xBAD0BAD0=FAIL"

clean:
	rm -rf $(BUILD)

FORCE:
