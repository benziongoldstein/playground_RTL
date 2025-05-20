# Memory Module

## Overview
The Memory Module serves as both instruction memory (i_mem) and data memory (d_mem) in the RISC-V CPU. It is a 128-byte array that can be read/written in different sizes (byte/halfword/word).

## Interface

### Inputs
- `clk`: Clock signal for synchronous operation
- `adrs_rd [31:0]`: Read address
- `wr_en`: Write enable signal
- `byt_en [3:0]`: Byte enable signals
  - `byt_en[0]`: Enable write to byte 0 (bits 7:0)
  - `byt_en[1]`: Enable write to byte 1 (bits 15:8)
  - `byt_en[2]`: Enable write to byte 2 (bits 23:16)
  - `byt_en[3]`: Enable write to byte 3 (bits 31:24)
- `adrs_wr [31:0]`: Write address
- `wr_data [31:0]`: Data to write

## Core Block Connections

### Instruction Memory (i_mem)
- **Program Counter (PC)**:
  - `pc_out` → `i_mem.adrs_rd`: Provides address to fetch next instruction
  - `rd_data` → Decoder: Outputs 32-bit instruction to be decoded
- **Write Interface** (unused during normal operation):
  - `byt_en`: Always `4'b1111` (full word writes only)
  - `wr_en`, `adrs_wr`, `wr_data`: Only used during boot/reset

### Data Memory (d_mem)
- **ALU**:
  - `alu_out` → `d_mem.adrs_rd` and `d_mem.adrs_wr`: Provides memory address
  - Address calculation: `rs1 + imm` for both loads and stores
- **Register File (RF)**:
  - For loads: `d_mem.rd_data` → `rf.write_data`
  - For stores: `rf.rs2_data` → `d_mem.wr_data`
- **Decoder**:
  - Generates `byt_en` based on instruction type:
    - `4'b0001` for SB (store byte)
    - `4'b0011` for SH (store halfword)
    - `4'b1111` for SW (store word)
- **Control Unit**:
  - `mem_wr_en` → `d_mem.wr_en`: Controls write operations
  - `mem_read`: Enables load operations

## Functionality

### Memory Organization
- 128-byte memory array (32 words)
- Byte-addressable (can read/write individual bytes)
- Word-aligned access (32-bit words)
- Little-endian byte ordering
  - Byte 0: bits 7:0
  - Byte 1: bits 15:8
  - Byte 2: bits 23:16
  - Byte 3: bits 31:24

### Read Operations
- Combinational read
- Outputs 32-bit word at `adrs_rd`
- For i_mem: Always reads full instruction
- For d_mem: Can read byte/halfword/word based on instruction

### Write Operations
- Synchronous write on rising clock edge
- Controlled by `wr_en` and `byt_en`
- `byt_en` bits control which bytes are written:
  - `byt_en[0]`: Enable write to byte 0
  - `byt_en[1]`: Enable write to byte 1
  - `byt_en[2]`: Enable write to byte 2
  - `byt_en[3]`: Enable write to byte 3

## Usage in CPU

### Instruction Memory (i_mem)
1. **Instruction Fetch**:
   - PC provides address via `adrs_rd`
   - `rd_data` outputs instruction to decoder
   - Always reads full 32-bit words
2. **Initialization**:
   - Write operations only during boot/reset
   - Always writes full words (`byt_en = 4'b1111`)

### Data Memory (d_mem)
1. **Load Instructions** (LW, LH, LB):
   - ALU calculates address (rs1 + imm)
   - `rd_data` outputs data to register file
2. **Store Instructions** (SW, SH, SB):
   - ALU calculates address (rs1 + imm)
   - Register file provides data via `wr_data`
   - Decoder sets `byt_en` based on instruction
   - Control unit enables write via `wr_en`

## Example Instruction Flow

### Load Word (LW)
1. PC → i_mem.adrs_rd: Fetch instruction
2. i_mem.rd_data → Decoder: Decode LW instruction
3. Decoder → Control: Generate load control signals
4. ALU → d_mem.adrs_rd: Calculate load address (rs1 + imm)
5. d_mem.rd_data → RF: Load data into register

### Store Word (SW)
1. PC → i_mem.adrs_rd: Fetch instruction
2. i_mem.rd_data → Decoder: Decode SW instruction
3. Decoder → Control: Generate store control signals
4. ALU → d_mem.adrs_wr: Calculate store address (rs1 + imm)
5. RF → d_mem.wr_data: Provide data to store
6. Decoder → d_mem.byt_en: Set to `4'b1111` for word store
7. Control → d_mem.wr_en: Enable write operation

## Implementation Details
- Uses SystemVerilog array for memory storage
- Combines combinational read with synchronous write
- Byte enables allow for byte/halfword/word operations
- Little-endian byte ordering

## Testing
The memory's functionality should be verified through:
1. Word read/write tests
2. Byte-level write tests
3. Address alignment tests
4. Read/write timing tests
5. Integration tests with PC and ALU

## Future Improvements
1. Increase memory size
2. Add memory protection
3. Implement cache
4. Add memory-mapped I/O
5. Support for different endianness
6. Add memory initialization
7. Implement memory wait states
8. Add debug features 