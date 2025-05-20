# Simple RISC-V Makefile

# Compiler and flags
CC = riscv64-unknown-elf-gcc
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

# Use RV32I base integer instruction set
CFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -ffreestanding -O0 -g
LDFLAGS = -T riscv.ld -nostdlib -nostartfiles
ASFLAGS = -march=rv32i -mabi=ilp32

# Source files
SRCS = main.c
ASM_SRCS = crt0.S
OBJS = $(SRCS:.c=.o) $(ASM_SRCS:.S=.o)

# Assembly-only mode (no C files)
ASM_TEST = test.S
ASM_TEST_OBJ = $(ASM_TEST:.S=.o)

# Default target
all: program.bin program.dump inst_mem.sv program.hex

# Assembly-only target
asm: test.bin test.dump test_inst_mem.sv test.hex

# Make sure to rebuild object files on makefile change
$(OBJS): Makefile
$(ASM_TEST_OBJ): Makefile

# Force clean before building to ensure we use our custom assembly
.PHONY: rebuild rebuild-asm
rebuild: clean all
rebuild-asm: clean asm

# Regular build (C + assembly)
program.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

program.bin: program.elf
	$(OBJCOPY) -O binary $< $@

program.dump: program.elf
	$(OBJDUMP) -D $< > $@

# Assembly-only build
test.o: test.S
	$(CC) $(CFLAGS) -c $< -o $@

test.elf: test.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

test.bin: test.elf
	$(OBJCOPY) -O binary $< $@

test.dump: test.elf
	$(OBJDUMP) -D $< > $@

# Generate clean version of disassembly (no pseudo-instructions, numeric registers)
program_clean.dump: program.elf
	$(OBJDUMP) -M numeric -M no-aliases -D $< > $@

test_clean.dump: test.elf
	$(OBJDUMP) -M numeric -M no-aliases -D $< > $@

# Generate SystemVerilog memory file directly
inst_mem.sv: program.elf
	$(OBJCOPY) --srec-len 1 --output-target=verilog $< $@

test_inst_mem.sv: test.elf
	$(OBJCOPY) --srec-len 1 --output-target=verilog $< $@
	cp $@ inst_mem.sv  # Create a copy with the standard name for simulators

# Generate Verilog readmemh compatible hex file
program.hex: program.bin
	xxd -p -c4 $< > $@

test.hex: test.bin
	xxd -p -c4 $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

# Force verbose output during compilation
.SILENT: 

clean:
	rm -f *.o *.elf *.bin *.dump *_clean.dump *.sv *.hex

.PHONY: all clean rebuild asm rebuild-asm 