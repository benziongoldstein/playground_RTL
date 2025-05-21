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

# Directory setup
TARGET_DIR = ../target/core
VERIF_DIR = ../verif/core

# Create target directory if it doesn't exist
$(shell mkdir -p $(TARGET_DIR))

# Source files
SRCS = main.c
ASM_SRCS = crt0.S
OBJS = $(SRCS:.c=.o) $(ASM_SRCS:.S=.o)
TARGET_OBJS = $(addprefix $(TARGET_DIR)/, $(OBJS))

# Assembly-only mode (no C files)
ASM_TEST = test.S
ASM_TEST_OBJ = $(TARGET_DIR)/$(ASM_TEST:.S=.o)

# Default target
all: $(TARGET_DIR)/program.bin $(TARGET_DIR)/program.dump $(TARGET_DIR)/inst_mem.sv $(TARGET_DIR)/program.hex

# Assembly-only target
asm: $(TARGET_DIR)/test.bin $(TARGET_DIR)/test.dump $(TARGET_DIR)/test_inst_mem.sv $(TARGET_DIR)/test.hex

# Make sure to rebuild object files on makefile change
$(TARGET_OBJS): Makefile
$(ASM_TEST_OBJ): Makefile

# Force clean before building to ensure we use our custom assembly
.PHONY: rebuild rebuild-asm
rebuild: clean all
rebuild-asm: clean asm

# Regular build (C + assembly)
$(TARGET_DIR)/program.elf: $(TARGET_OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET_DIR)/program.bin: $(TARGET_DIR)/program.elf
	$(OBJCOPY) -O binary $< $@

$(TARGET_DIR)/program.dump: $(TARGET_DIR)/program.elf
	$(OBJDUMP) -D $< > $@

# Assembly-only build
$(TARGET_DIR)/test.o: test.S
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET_DIR)/test.elf: $(TARGET_DIR)/test.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

$(TARGET_DIR)/test.bin: $(TARGET_DIR)/test.elf
	$(OBJCOPY) -O binary $< $@

$(TARGET_DIR)/test.dump: $(TARGET_DIR)/test.elf
	$(OBJDUMP) -D $< > $@

# Generate clean version of disassembly (no pseudo-instructions, numeric registers)
$(TARGET_DIR)/program_clean.dump: $(TARGET_DIR)/program.elf
	$(OBJDUMP) -M numeric -M no-aliases -D $< > $@

$(TARGET_DIR)/test_clean.dump: $(TARGET_DIR)/test.elf
	$(OBJDUMP) -M numeric -M no-aliases -D $< > $@

# Generate SystemVerilog memory file directly
$(TARGET_DIR)/inst_mem.sv: $(TARGET_DIR)/program.elf
	$(OBJCOPY) --srec-len 1 --output-target=verilog $< $@
	cp $@ $(VERIF_DIR)/inst_mem.sv  # Copy to verification directory

$(TARGET_DIR)/test_inst_mem.sv: $(TARGET_DIR)/test.elf
	$(OBJCOPY) --srec-len 1 --output-target=verilog $< $@
	cp $@ $(VERIF_DIR)/inst_mem.sv  # Copy to verification directory

# Generate Verilog readmemh compatible hex file
$(TARGET_DIR)/program.hex: $(TARGET_DIR)/program.bin
	xxd -p -c4 $< > $@

$(TARGET_DIR)/test.hex: $(TARGET_DIR)/test.bin
	xxd -p -c4 $< > $@

# Compile C files to target directory
$(TARGET_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile assembly files to target directory
$(TARGET_DIR)/%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

# Force verbose output during compilation
.SILENT: 

clean:
	rm -f $(TARGET_DIR)/*.o $(TARGET_DIR)/*.elf $(TARGET_DIR)/*.bin $(TARGET_DIR)/*.dump $(TARGET_DIR)/*_clean.dump $(TARGET_DIR)/*.sv $(TARGET_DIR)/*.hex

.PHONY: all clean rebuild asm rebuild-asm 