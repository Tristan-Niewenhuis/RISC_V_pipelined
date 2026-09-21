# makefile to convert C codo and assembly startup code to coe file for
# vivado block memory.

BASENAME=embedded_iot
EMBENCH_DIR=../../embench-iot
BUILD_DIR_FROM_EMBENCH=../RISC_V/embench-iot-files

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
LDFLAGS="-O2 -march=rv32i_zicsr_zicntr -mabi=ilp32 -Wl,--gc-sections -Wl,--no-warn-rwx-segments -static -T ${BUILD_DIR_FROM_EMBENCH}/link.ld"

all: elf dis coe

#set gsf to about #MHZ
elf:
	cd $(EMBENCH_DIR) && scons \
		--config-dir=${BUILD_DIR_FROM_EMBENCH} \
		--build-dir=${BUILD_DIR_FROM_EMBENCH}/build \
		cc=$(GCC) \
		cflags=$(CFLAGS) \
		ldflags=$(LDFLAGS) \
		user_libs=m \
		gsf=1

dis: elf
	powershell -NoProfile -ExecutionPolicy Bypass -File .\disassemble.ps1

coe: elf
	$(TOOLPATH)/$(OBJCOPY) -O binary $(BASENAME).elf $(BASENAME).bin
	xxd -c 4 -g 4 -e $(BASENAME).bin  | cut -d ' ' -f 2 > tmp1
	echo "memory_initialization_radix = 16;" > tmp2
	echo -n "memory_initialization_vector = " >> tmp2
	for i in `head -n -1 tmp1`; do echo -n $$i,' ' ; done >> tmp2
	echo `tail -1 tmp1`';' >> tmp2
	mv tmp2 $(BASENAME).coe
	rm tmp1

clean:
	if exist "./build" rmdir /S /Q "./build" 




#   $(TOOLPATH)/$(GCC) -march=rv32i -mabi=ilp32 -c riscv_startup.S
# 	$(TOOLPATH)/$(GCC) -S -I$INCPATH -march=rv32i -mabi=ilp32 $(BASENAME).c
# 	mv $(BASENAME).s $(BASENAME).S
# 	$(TOOLPATH)/$(AS) -march=rv32i $(BASENAME).S -alh -o $(BASENAME).o > $(BASENAME).lst
# 	$(TOOLPATH)/$(LD) $(BASENAME).o riscv_startup.o -o $(BASENAME).elf -T link.ld
# 	$(TOOLPATH)/$(LD) $(BASENAME).o riscv_startup.o -o $(BASENAME)_spike.elf -T link_spike.ld
# 	$(TOOLPATH)/$(OBJCOPY) -O binary $(BASENAME).elf $(BASENAME).bin
# 	$(TOOLPATH)/$(OBJDUMP) -d -M no-aliases,numeric $(BASENAME).o > $(BASENAME).S
# 	$(TOOLPATH)/$(OBJDUMP) -D -M no-aliases,numeric $(BASENAME).elf > $(BASENAME).dis
# 	xxd -c 4 -g 4 -e $(BASENAME).bin  | cut -d ' ' -f 2 > tmp1
# 	echo "memory_initialization_radix = 16;" > tmp2
# 	echo -n "memory_initialization_vector = " >> tmp2
# 	for i in `head -n -1 tmp1`; do echo -n $$i,' ' ; done >> tmp2
# 	echo `tail -1 tmp1`';' >> tmp2
# 	mv tmp2 $(BASENAME).coe
# 	rm tmp1
