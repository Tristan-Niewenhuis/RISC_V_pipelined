# makefile to convert C codo and assembly startup code to coe file for
# vivado block memory.

BASENAME=embedded_iot
EMBENCH_DIR=../../embench-iot
BUILD_DIR_FROM_EMBENCH=../RISC_V/embench-iot-files
STARTUP=harvard_startup

# TOOLPATH=/opt/Xilinx/2025.1/gnu/riscv/lin/riscv64-unknown-elf/bin
# INCPATH=/opt/Xilinx/2025.1/gnu/riscv/lin/riscv64-unknown-elf/riscv32-xilinx-elf/usr/include
TOOLPATH=C:/AMDDesignTools/2026.1/gnu/riscv/nt/bin
INCPATH=C:/AMDDesignTools/2026.1/gnu/riscv/nt/riscv32-xilinx-elf/usr/include
GCC=riscv64-unknown-elf-gcc
AS=riscv64-unknown-elf-as
LD=riscv64-unknown-elf-ld
OBJCOPY=riscv64-unknown-elf-objcopy
OBJDUMP=riscv64-unknown-elf-objdump

CFLAGS="-O2 -ffunction-sections -fdata-sections -march=rv32i_zicsr_zicntr -mabi=ilp32"
LDFLAGS="-O2 -march=rv32i_zicsr_zicntr -mabi=ilp32 -Wl,--gc-sections -Wl,--no-warn-rwx-segments -static -o $(BUILD_DIR_FROM_EMBENCH)/$(STARTUP).o -T ${BUILD_DIR_FROM_EMBENCH}/link.ld"

all: elf dis coe

#set gsf to about #MHZ
elf:
	$(TOOLPATH)/$(GCC) $(CFLAGS) -c $(STARTUP).S
	cd $(EMBENCH_DIR) && scons \
		--config-dir=${BUILD_DIR_FROM_EMBENCH} \
		--build-dir=${BUILD_DIR_FROM_EMBENCH}/build \
		cc=$(GCC) \
		cflags=$(CFLAGS)\
		ldflags=$(LDFLAGS) \
		user_libs=m \
		gsf=1

dis: elf
	powershell -NoProfile -ExecutionPolicy Bypass -File .\disassemble.ps1

coe: elf
	powershell -NoProfile -ExecutionPolicy Bypass -File .\make_coe.ps1

clean:
	if exist "./build" rmdir /S /Q "./build" 





