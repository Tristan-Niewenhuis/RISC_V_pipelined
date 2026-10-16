# Bare-metal RV32 assembly pipeline test. Override CROSS if your prefix differs.
# Example: make CROSS=riscv32-unknown-elf-
CROSS       ?= riscv64-unknown-elf-
CC          := $(CROSS)gcc
OBJDUMP     := $(CROSS)objdump
READELF     := $(CROSS)readelf
PYTHON      ?= python3
BUILD_DIR   ?= build
TARGET      := $(BUILD_DIR)/pipeline_test
SRC         := pipeline_test.S
LDSCRIPT    := linker.ld
OBJ         := $(TARGET).o
ELF         := $(TARGET).elf
MAP         := $(TARGET).map
DUMP        := $(TARGET).lst
ROM_COE     := $(BUILD_DIR)/rom.coe
RAM_COE     := $(BUILD_DIR)/ram.coe
RAM_IMAGE_BYTES ?= 0x00010000

# The source uses RV32I instructions only. ARCH may be changed to match your
# current setup (e.g. rv32i_zicsr_zicntr); no CSR instructions are executed.
ARCH        ?= rv32i
ABI         ?= ilp32
ARCHFLAGS   := -march=$(ARCH) -mabi=$(ABI)
ASFLAGS     := $(ARCHFLAGS) -g -Wa,--fatal-warnings
LDFLAGS     := $(ARCHFLAGS) -nostdlib -nostartfiles -static \
               -Wl,--gc-sections -Wl,--build-id=none \
               -Wl,-Map=$(MAP) -T $(LDSCRIPT)

.PHONY: all clean inspect toolchain-check
all: $(ELF) $(DUMP) $(ROM_COE) $(RAM_COE)

$(BUILD_DIR):
	mkdir -p $@

$(OBJ): $(SRC) | $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(ELF): $(OBJ) $(LDSCRIPT)
	$(CC) $(LDFLAGS) -o $@ $(OBJ)

$(DUMP): $(ELF)
	$(OBJDUMP) -d -M no-aliases,numeric $< > $@

# The generator writes both COEs. Make RAM depend on ROM so parallel builds do
# not run the generator twice; the RAM rule repairs a missing RAM file if needed.
$(ROM_COE): $(ELF) tools/elf_to_coe.py
	$(PYTHON) tools/elf_to_coe.py $(ELF) --rom $(ROM_COE) --ram $(RAM_COE) --ram-bytes $(RAM_IMAGE_BYTES)

$(RAM_COE): $(ROM_COE)
	@if [ ! -f $@ ]; then \
	  $(PYTHON) tools/elf_to_coe.py $(ELF) --rom $(ROM_COE) --ram $(RAM_COE) --ram-bytes $(RAM_IMAGE_BYTES); \
	fi

inspect: $(ELF) $(DUMP)
	$(READELF) -h -S -l $(ELF)
	@echo "Disassembly: $(DUMP)"

# Check that all required commands are on PATH.
toolchain-check:
	@command -v $(CC) >/dev/null || { echo "Missing $(CC); set CROSS=..."; exit 1; }
	@command -v $(OBJDUMP) >/dev/null || { echo "Missing $(OBJDUMP); set CROSS=..."; exit 1; }
	@command -v $(READELF) >/dev/null || { echo "Missing $(READELF); set CROSS=..."; exit 1; }
	@$(PYTHON) --version

clean:
	rm -rf $(BUILD_DIR)
