# Minimal RISC-V Application

This folder contains the simplest possible RISC-V application setup for testing RTL CPU implementations.

## Files

- `crt0.S` - Minimal startup code that sets up the stack and calls main
- `riscv.ld` - Minimal linker script that defines memory layout
- `main.c` - Simple C program for testing
- `Makefile` - Build script to compile the application

## Building

To build the application, simply run:

```
make
```

This will produce:
- `program.elf` - ELF executable file
- `program.bin` - Raw binary file for loading into memory
- `program.dump` - Disassembly for debugging and verification
- `program_clean.dump` - Clean disassembly with numeric registers and no pseudo-instructions
- `inst_mem.sv` - SystemVerilog memory initialization file (generated directly from the ELF)
- `program.hex` - Verilog readmemh-compatible hex file

## Memory Output Formats

The build process automatically generates multiple output formats:

1. **SystemVerilog Memory File** (`inst_mem.sv`):
   ```systemverilog
   @00000000
   00000297 01028293 30529073 00000013 00000013 00100793 00200813 00F807B3
   0000007E
   ```
   This format is generated directly by the RISC-V toolchain and contains:
   - Memory addresses marked with `@` followed by an 8-digit hex address
   - Instruction/data words in groups of 8 bytes per line
   - Compatible with most SystemVerilog simulators

2. **Verilog readmemh Format** (`program.hex`):
   ```
   00000297
   01028293
   // ...
   ```
   Use this with the Verilog `$readmemh` function:
   ```verilog
   initial begin
     $readmemh("program.hex", memory);
   end
   ```

## Memory Map

The linker script configures a simple memory layout:
- RAM starts at address 0x00000000
- RAM size is 4KB
- Stack starts at the top of RAM (0x00001000) and grows downward

## Customizing

To create your own test program, simply modify `main.c`. The build system is configured to compile for the RV32I base integer instruction set. 