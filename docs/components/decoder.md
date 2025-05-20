# Decoder Component

## Overview
The Decoder is a critical component in the RISC-V CPU pipeline that translates 32-bit RISC-V instructions into control signals and extracts necessary fields for execution. It operates in the Instruction Decode (ID) stage of the pipeline, taking raw instruction bits as input and producing control signals and register addresses that drive the rest of the CPU.

## Interface

### Inputs
- `instruction [31:0]`: The 32-bit RISC-V instruction to decode

### Outputs
- `rs1 [4:0]`: Source register 1 address (bits 19:15 of instruction)
- `rs2 [4:0]`: Source register 2 address (bits 24:20 of instruction)
- `rd [4:0]`: Destination register address (bits 11:7 of instruction)
- `imm [31:0]`: Sign-extended immediate value for I-type instructions
- `ctrl`: Control signals bundle (type `t_ctrl`) containing:
  - `alu_op`: ALU operation to perform
  - `sel_dmem_wb`: Select between data memory and ALU output for writeback
  - `sel_next_pc_alu_out`: Select between PC+4 and ALU output for next PC
  - `sel_wb`: Select between PC+4 and data for register writeback
  - `mem_byt_en [3:0]`: Memory byte enables for byte/halfword operations
  - `mem_wr_en`: Memory write enable
  - `reg_wr_en`: Register file write enable
  - `sel_alu_pc`: Select between PC and register for ALU input 1
  - `sel_alu_imm`: Select between immediate and register for ALU input 2

## Functionality

### Instruction Decoding
The decoder extracts register addresses directly from fixed positions in the instruction:
- `rs1` (bits 19:15): First source register
- `rs2` (bits 24:20): Second source register
- `rd` (bits 11:7): Destination register

### Immediate Generation
Currently supports I-type instructions (e.g., ADDI):
- Extracts immediate from bits 31:20
- Sign-extends to 32 bits
- For R-type instructions, immediate is set to 0

### Control Signal Generation
The decoder generates control signals based on the instruction opcode (bits 6:0):

#### Supported Instructions
1. R-type (opcode 7'b0110011)
   - Example: ADD
   - Uses register operands (sel_alu_imm = 0)
   - Writes result to register file

2. I-type (opcode 7'b0010011)
   - Example: ADDI
   - Uses immediate operand (sel_alu_imm = 1)
   - Writes result to register file

### Default Control Values
When not explicitly set, control signals default to:
- `alu_op`: ALU_ADD
- `sel_dmem_wb`: 0 (select ALU output)
- `sel_next_pc_alu_out`: 0 (select PC+4)
- `sel_alu_pc`: 0 (select register)
- `sel_alu_imm`: 0 (select register)
- `reg_wr_en`: 1 (enable register write)
- `mem_byt_en`: 4'b0000 (no memory access)
- `mem_wr_en`: 0 (no memory write)
- `sel_wb`: 1 (select ALU output for writeback)

## Implementation Details
- Pure combinational logic (no clock needed)
- Uses SystemVerilog struct `t_ctrl` for control signals
- Implements sign extension for immediate values
- Default control values ensure safe operation for unsupported instructions

## Connections
- **Input**: Receives instruction from Instruction Memory
- **Outputs to**:
  - Register File: rs1, rs2, rd addresses
  - ALU: Operation code and operand selection signals
  - Memory: Write enables and byte enables
  - Program Counter: Next PC selection signal
  - Register File: Write enable and data selection

## Testing
The decoder's functionality should be verified through:
1. Instruction decoding tests for each supported instruction type
2. Control signal generation tests
3. Immediate value extraction and sign extension tests
4. Default control signal behavior tests

## Future Improvements
1. Support for additional instruction types:
   - S-type (store)
   - B-type (branch)
   - J-type (jump)
   - U-type (upper immediate)
2. Enhanced immediate value generation for different instruction formats
3. Additional control signals for new instruction types
4. Support for compressed instructions (RVC) 