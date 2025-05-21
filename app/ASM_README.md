# Assembly-Only Testing Mode

This document explains how to write and run pure assembly tests without needing a C main function.

## Writing Assembly Tests

To create a simple assembly test:

1. Edit the `test.S` file in this directory
2. Write your RISC-V assembly instructions directly
3. Make sure your file starts with:
   ```assembly
   .section .text
   .global _start
   
   _start:
       # Your instructions here
   ```
4. End with an infinite loop or halt instruction:
   ```assembly
   j .   # Infinite loop
   ```

## Building and Running

To build your assembly-only test:

```bash
make asm
```

This will:
- Compile your assembly in `test.S`
- Generate `test.elf`, `test.bin`, and `test.dump`
- Create `test_inst_mem.sv` for RTL simulation
- Also create a copy as `inst_mem.sv` for compatibility

## Example Assembly Test

Here's a simple example test (already in test.S):

```assembly
.section .text
.global _start

_start:
    # Your test instructions here
    nop                 # No operation
    li a0, 1            # Load immediate 1 into a0
    li a1, 2            # Load immediate 2 into a1
    add a2, a0, a1      # Add a0 and a1, store in a2
    sub a3, a2, a0      # Subtract a0 from a2, store in a3
    
    # Simple infinite loop at the end
    j .                 # Jump to current address (infinite loop)
```

## Common RISC-V Instructions

Here are some common RV32I instructions to use in your tests:

- `li rd, imm`: Load immediate value into register
- `add rd, rs1, rs2`: Add two registers
- `sub rd, rs1, rs2`: Subtract rs2 from rs1
- `and rd, rs1, rs2`: Bitwise AND
- `or rd, rs1, rs2`: Bitwise OR
- `xor rd, rs1, rs2`: Bitwise XOR
- `sll rd, rs1, rs2`: Shift left logical
- `srl rd, rs1, rs2`: Shift right logical
- `sra rd, rs1, rs2`: Shift right arithmetic
- `lw rd, imm(rs1)`: Load word from memory
- `sw rs2, imm(rs1)`: Store word to memory
- `beq rs1, rs2, offset`: Branch if equal
- `bne rs1, rs2, offset`: Branch if not equal
- `jal rd, offset`: Jump and link
- `jalr rd, rs1, offset`: Jump and link register

## Using with Simulation

To use your assembly test in simulation after building with `make asm`:

use the builder script:

```bash
python ../build/builder.py core -hw -sim
``` 