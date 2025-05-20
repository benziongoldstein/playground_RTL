# Register File (RF) - Core Connection Conclusion

## Register File Variables and Their Roles

### Address Variables (5 bits each)
1. **rs1[4:0]**
   - Source register 1 address
   - Used to select first operand
   - Example: `5'b00001` selects x1
   - Always used for:
     * First operand in arithmetic operations
     * Base address in memory operations
     * Source register in immediate operations

2. **rs2[4:0]**
   - Source register 2 address
   - Used to select second operand
   - Example: `5'b00010` selects x2
   - Used for:
     * Second operand in arithmetic operations
     * Data to store in memory operations

3. **rd[4:0]**
   - Destination register address
   - Selects where to write results
   - Example: `5'b00011` selects x3
   - Used for:
     * Storing ALU results
     * Storing loaded data from memory
     * Storing PC+4 for jump instructions

### Data Variables (32 bits each)
1. **write_d[31:0]**
   - Data to be written to register
   - Can come from:
     * ALU result
     * Memory read data
     * PC+4 (for jump instructions)
   - Only written if write_e is high

2. **reg_data1[31:0]**
   - Data read from rs1
   - Goes to:
     * ALU first input
     * Memory address calculation
   - Always available (combinational)

3. **reg_data2[31:0]**
   - Data read from rs2
   - Goes to:
     * ALU second input
     * Memory write data
   - Always available (combinational)

### Control Variables
1. **write_e**
   - Write enable signal
   - Controls when register writes happen
   - High for:
     * Arithmetic operations
     * Load operations
     * Jump operations
   - Low for:
     * Store operations
     * Branch operations

## Connection to Core Components

### ALU Connection
- **Inputs to ALU:**
  - `reg_data1` → ALU's first operand
  - `reg_data2` → ALU's second operand
- **Output from ALU:**
  - ALU result → `write_d` (when selected)

### Memory Connection
- **For Load Operations:**
  - `reg_data1` → Memory address calculation
  - Memory data → `write_d`
- **For Store Operations:**
  - `reg_data1` → Memory address calculation
  - `reg_data2` → Data to store in memory

### Control Unit Connection
- Receives control signals:
  - `write_e` for register writes
  - Selection signals for `write_d` multiplexer
- Part of decode and writeback stages

## Detailed Code Implementation

### Module Declaration
```verilog
module rf(
    input logic         clk,        // Clock signal for synchronous operations
    input logic [4:0]   rs1,        // Source register 1 address
    input logic [4:0]   rs2,        // Source register 2 address
    input logic [4:0]   rd,         // Destination register address
    input logic         write_e,    // Write enable signal
    input logic [31:0]  write_d,    // Data to write

    output logic [31:0] reg_data1,  // Data from rs1
    output logic [31:0] reg_data2   // Data from rs2
);
```

### Internal Storage
```verilog
logic [31:0] reg_file [31:0];  // 32 registers, each 32 bits wide
```
- Creates an array of 32 registers
- Each register is 32 bits wide
- Indexed from 0 to 31 (x0 to x31)

### Register Read Logic
```verilog
assign reg_data1 = (rs1 == 5'b0) ? 32'b0 : reg_file[rs1];
assign reg_data2 = (rs2 == 5'b0) ? 32'b0 : reg_file[rs2];
```
- Combinational logic (always active)
- Special case for x0 (rs1/rs2 = 0):
  - Always returns 0 regardless of stored value
- For other registers:
  - Directly outputs the register's value
- No clock needed for reads (asynchronous)

### Register Write Logic
```verilog
`DFF_EN(reg_file[rd], write_d, clk, write_e)
```
This macro expands to:
```verilog
always_ff @(posedge clk) begin
    if (write_e) begin
        reg_file[rd] <= write_d;
    end
end
```
- Synchronous write (only on clock edge)
- Only writes if write_e is high
- Updates the register specified by rd
- Note: Writes to x0 (rd = 0) are ignored by hardware

### Key Implementation Details

1. **Register File Organization**
   - 32 registers (x0-x31)
   - Each register is 32 bits
   - Total storage: 32 × 32 = 1024 bits
   - Dual read ports (can read two registers simultaneously)
   - Single write port (one write per cycle)

2. **Read Path**
   - Two independent read ports
   - Combinational logic (no clock needed)
   - Zero register (x0) hardwired to 0
   - Direct access to register values

3. **Write Path**
   - Single write port
   - Synchronous (clocked) operation
   - Write enable control
   - Write to x0 is ignored (hardware implementation)

4. **Control Logic**
   - Write enable (write_e) controls register updates
   - No additional control needed for reads
   - Zero register handling is built into read logic

### Timing Considerations

1. **Read Timing**
   - Combinational path: rs1/rs2 → reg_data1/reg_data2
   - No clock cycle needed
   - Data available immediately after address change

2. **Write Timing**
   - Synchronous path: write_d → reg_file[rd]
   - One clock cycle needed
   - Data written on rising edge of clock
   - Only if write_e is high

### Example Operation Flow

1. **Arithmetic Operation (e.g., add x3, x1, x2)**
   ```verilog
   // Read phase (combinational)
   rs1 = 5'b00001;  // x1
   rs2 = 5'b00010;  // x2
   // reg_data1 and reg_data2 immediately available
   
   // Write phase (synchronous)
   rd = 5'b00011;   // x3
   write_e = 1'b1;  // Enable write
   write_d = alu_result;  // From ALU
   // Write happens at next clock edge
   ```

2. **Load Operation (e.g., lw x3, 0(x1))**
   ```verilog
   // Read phase
   rs1 = 5'b00001;  // x1 for address
   // reg_data1 used for memory address
   
   // Write phase
   rd = 5'b00011;   // x3
   write_e = 1'b1;  // Enable write
   write_d = mem_data;  // From memory
   // Write happens at next clock edge
   ```

3. **Store Operation (e.g., sw x2, 0(x1))**
   ```verilog
   // Read phase
   rs1 = 5'b00001;  // x1 for address
   rs2 = 5'b00010;  // x2 for data
   // reg_data1 and reg_data2 used for memory operation
   
   // No write phase (write_e = 0)
   ```

## Key Points
1. Register addresses (rs1, rs2, rd) are 5 bits to select from 32 registers
2. Data paths are 32 bits wide for RISC-V word size
3. Read operations are immediate (combinational)
4. Write operations are clocked and controlled by write_e
5. x0 is special: always reads as 0, writes are ignored 