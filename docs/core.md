# Core Module: Inputs and Outputs

The core module is the top-level integration of the RISC-V CPU. It coordinates instruction fetch, decode, execution, memory access, and write-back by connecting all major components (PC, ALU, Register File, Memory, Decoder, Control Unit).

## Inputs
- `clk` (input logic):
  - The main clock signal for the CPU. All synchronous operations (register and memory updates) occur on the rising edge of this clock.
- `rst` (input logic):
  - The reset signal. When asserted, it resets the program counter and other stateful elements to their initial values, starting program execution from the beginning.

## Outputs
- The core module, as currently defined, does not have explicit output ports. Instead, it operates internally and communicates with submodules (memory, register file, etc.) via internal signals.
- In a more complete system, the core might expose outputs such as:
  - `pc_out`: The current program counter value (useful for debugging or external monitoring)
  - `reg_wr_data`: The data being written back to the register file
  - `mem_rd_data`: Data read from data memory
  - `wb_data`: The value selected for write-back (from ALU or memory)

## Notes
- All communication with the outside world (e.g., memory-mapped I/O, interrupts) would typically be handled by extending the core's interface with additional input/output ports as needed.
- For simulation and integration, internal signals can be monitored to verify correct operation.

---

**Summary Table:**

| Port Name   | Direction | Width   | Description                                 |
|-------------|-----------|---------|---------------------------------------------|
| clk         | input     | 1 bit   | Main clock signal                           |
| rst         | input     | 1 bit   | Synchronous reset signal                    |

If you need a more detailed breakdown of internal signals or want to extend the core's interface, let me know! 

---

# Core Module Code Structure and Flow

The `core` module implements the five classic stages of a RISC-V pipeline:
1. **IF (Instruction Fetch)**: Fetches the next instruction from instruction memory using the program counter (PC).
2. **ID (Instruction Decode)**: Decodes the instruction, extracts register addresses, immediate values, and control signals.
3. **EX (Execute)**: Performs arithmetic or logic operations using the ALU.
4. **MEM (Memory Access)**: Accesses data memory for load/store instructions.
5. **WB (Write Back)**: Writes results back to the register file.

## Main Components and Connections
- **Program Counter (PC)**: Keeps track of the current instruction address. Can be updated by normal increment or by jump/branch instructions.
- **Instruction Memory (`i_mem`)**: Read-only memory that provides the instruction at the address given by the PC.
- **Decoder**: Decodes the fetched instruction, providing register addresses, immediate values, and control signals for the rest of the pipeline.
- **Register File (RF)**: Stores general-purpose registers. Provides source operands to the ALU and receives results in the write-back stage.
- **ALU**: Executes arithmetic and logic operations. Receives operands from the register file or immediate values.
- **Data Memory (`d_mem`)**: Used for load and store instructions. The ALU provides the address, and the register file provides data for stores.
- **Control Unit**: Generates control signals that determine the operation of multiplexers, write enables, and ALU operation codes.

## Data and Control Flow
- The PC provides the address to `i_mem`, which outputs the instruction.
- The instruction is decoded to determine the operation, source/destination registers, and immediate values.
- The register file provides operands to the ALU, or the PC/immediate is used depending on the instruction type.
- The ALU computes results or memory addresses.
- For load/store instructions, the data memory is accessed using the ALU result as the address.
- The result (from the ALU or memory) is written back to the register file in the write-back stage.
- Control signals from the decoder and control unit manage multiplexers and enable signals throughout the pipeline.

## Example Flow (LW Instruction)
1. **IF**: PC fetches instruction from `i_mem`.
2. **ID**: Decoder identifies LW, extracts source register and immediate.
3. **EX**: ALU computes address (`rs1 + imm`).
4. **MEM**: Data memory reads from computed address.
5. **WB**: Loaded data is written to destination register in the register file.

This modular structure allows for clear separation of concerns and easy extension or modification of the CPU design. 