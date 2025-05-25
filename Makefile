RISCV_GCC = riscv64-unknown-elf-gcc
RISCV_OBJCOPY = riscv64-unknown-elf-objcopy
RISCV_ARCH = -march=rv32i -mabi=ilp32
RISCV_FLAGS = -nostdlib -nostartfiles $(RISCV_ARCH)

# Directory structure
TARGET_DIR = target/app

# Default target: build from C (main.c) and assembly (crt0.S)
all: $(TARGET_DIR)/inst_mem.hex

# Create target directory
$(TARGET_DIR):
	mkdir -p $(TARGET_DIR)

# Generate assembly from C (always do this when building)
$(TARGET_DIR)/main.s: $(TARGET_DIR) app/main.c
	$(RISCV_GCC) $(RISCV_FLAGS) -S app/main.c -o $(TARGET_DIR)/main.s
	@echo "Generated assembly from C:"
	@cat $(TARGET_DIR)/main.s

# Build from C and assembly
$(TARGET_DIR)/test.elf: $(TARGET_DIR)/main.s app/crt0.S app/riscv.ld
	$(RISCV_GCC) $(RISCV_FLAGS) -T app/riscv.ld app/crt0.S app/main.c -o $(TARGET_DIR)/test.elf

# Build from assembly only
$(TARGET_DIR)/test_asm.elf: $(TARGET_DIR) app/crt0.S app/test.S app/riscv.ld
	$(RISCV_GCC) $(RISCV_FLAGS) -T app/riscv.ld app/crt0.S app/test.S -o $(TARGET_DIR)/test_asm.elf

# Generate hex files
$(TARGET_DIR)/inst_mem.hex: $(TARGET_DIR)/test.elf
	$(RISCV_OBJCOPY) -O ihex $(TARGET_DIR)/test.elf $(TARGET_DIR)/inst_mem.hex

$(TARGET_DIR)/inst_mem_asm.hex: $(TARGET_DIR)/test_asm.elf
	$(RISCV_OBJCOPY) -O ihex $(TARGET_DIR)/test_asm.elf $(TARGET_DIR)/inst_mem_asm.hex

# Clean all generated files
clean:
	rm -rf $(TARGET_DIR)

# List all generated files
list:
	@echo "Generated files in $(TARGET_DIR):"
	@ls -l $(TARGET_DIR) 2>/dev/null || echo "No files found"

# Show the generated assembly (if you want to see it again)
show_asm: $(TARGET_DIR)/main.s

asm: $(TARGET_DIR)/inst_mem_asm.hex
	@echo "Assembly program built."

.PHONY: all clean show_asm list asm
