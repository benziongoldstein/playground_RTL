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

# Source files
SRCS = main.c
ASM_SRCS = crt0.S
OBJS = $(SRCS:.c=.o) $(ASM_SRCS:.S=.o)

# Targets
all: program.bin program.dump inst_mem.sv program.hex

# Make sure to rebuild object files on makefile change
$(OBJS): Makefile

# Force clean before building to ensure we use our custom crt0.S
.PHONY: rebuild
rebuild: clean all

program.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

program.bin: program.elf
	$(OBJCOPY) -O binary $< $@

program.dump: program.elf
	$(OBJDUMP) -D $< > $@

# Generate clean version of disassembly (no pseudo-instructions, numeric registers)
program_clean.dump: program.elf
	$(OBJDUMP) -M numeric -M no-aliases -D $< > $@

# Generate SystemVerilog memory file directly
inst_mem.sv: program.elf
	$(OBJCOPY) --srec-len 1 --output-target=verilog $< $@

# Generate Verilog readmemh compatible hex file
program.hex: program.bin
	xxd -p -c4 $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

# Force verbose output during compilation
.SILENT: 

clean:
	rm -f *.o *.elf *.bin *.dump *_clean.dump *.sv *.hex

.PHONY: all clean rebuild 