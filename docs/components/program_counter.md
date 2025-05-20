# Program Counter (PC) Component

## Overview
The Program Counter is a fundamental component in the RISC-V CPU pipeline that manages instruction addresses. It keeps track of the current instruction's address and determines the next instruction's address. The PC operates in the Instruction Fetch (IF) stage of the pipeline and is crucial for sequential instruction execution and control flow.

## Interface

### Inputs
- `clk`: Clock signal for synchronous operation
- `rst`: Reset signal (active high)
- `sel_next_pc_alu_out`: Control signal to select next PC value
  - 0: Use PC+4 (sequential execution)
  - 1: Use ALU output (for branches/jumps)
- `alu_out [31:0]`: ALU result used as branch/jump target

### Outputs
- `pc_out [31:0]`: Current instruction address
- `pc_plus4 [31:0]`: Next sequential instruction address (PC+4)

## Functionality

### Address Generation
The PC generates two addresses:
1. `pc_out`: The current instruction address
   - Used by instruction memory to fetch the current instruction
   - Updated on every clock cycle
   - Resets to 0 when rst is active

2. `pc_plus4`: The next sequential instruction address
   - Always PC+4 (RISC-V instructions are 4 bytes)
   - Used for sequential execution
   - Available for branch/jump target selection

### Next PC Selection
The next PC value is selected based on `sel_next_pc_alu_out`:
- When 0 (default): PC+4 is selected for sequential execution
- When 1: ALU output is selected for branches/jumps
  - Used when executing branch or jump instructions
  - ALU calculates the target address

### Reset Behavior
- When rst is active, PC is reset to 0 on the next clock edge
- This ensures the CPU starts execution from the first instruction
- Reset is synchronous (requires clock edge to take effect)

## Implementation Details
- Uses synchronous D flip-flop for PC register
- Combines combinational logic (PC+4, mux) with sequential logic (PC register)
- Implements synchronous reset (using DFF_RST macro)
- Uses `DFF_RST` macro for register implementation
- Pure combinational logic for PC+4 and next PC selection

## Connections
- **Inputs from**:
  - ALU: Branch/jump target address
  - Control Unit: Next PC selection signal
- **Outputs to**:
  - Instruction Memory: Current instruction address
  - ALU: PC value for PC-relative addressing
  - Decoder: PC+4 for jump and link instructions

## Timing
- PC updates on rising edge of clock
- PC+4 and next PC selection are combinational
- Reset is synchronous (requires clock edge)
- Critical path: PC register → PC+4 → next PC mux → PC register

## Testing
The PC's functionality should be verified through:
1. Sequential execution tests (PC+4)
2. Branch/jump target selection tests
3. Reset behavior tests
4. Timing verification
5. Integration tests with ALU and instruction memory

## Future Improvements
1. Support for compressed instructions (RVC)
   - Modify PC+4 to PC+2 for 16-bit instructions
2. Additional control signals for different jump types
3. Pipeline integration considerations
4. Exception handling support
5. Debug features (PC value observation) 