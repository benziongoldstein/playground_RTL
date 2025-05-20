# Arithmetic Logic Unit (ALU)

## Overview
The Arithmetic Logic Unit (ALU) is a fundamental component of the CPU that performs arithmetic and logical operations on 32-bit operands. It supports a comprehensive set of operations defined in the RISC-V instruction set architecture.

## Interface

### Inputs
1. **alu_op[3:0]** (t_alu_op)
   - Operation select signal
   - Determines which operation to perform
   - Defined in cpu_pkg.sv as an enum

2. **alu_in1[31:0]**
   - First operand (32 bits)
   - Can be:
     * Register data (from RF)
     * Program Counter value (for PC-relative operations)

3. **alu_in2[31:0]**
   - Second operand (32 bits)
   - Can be:
     * Register data (from RF)
     * Immediate value (from instruction)
     * Constant 4 (for PC+4 calculation)

### Outputs
1. **alu_out[31:0]**
   - Result of the ALU operation (32 bits)
   - Used for:
     * Register write-back
     * Memory address calculation
     * Next PC calculation (for branches/jumps)

## Supported Operations

### Arithmetic Operations
1. **ADD (ALU_ADD = 4'b0000)**
   - Performs: alu_out = alu_in1 + alu_in2
   - Used for: ADD, ADDI, and PC+4 calculations
   - Example: `add x3, x1, x2` → x3 = x1 + x2

2. **SUB (ALU_SUB = 4'b1000)**
   - Performs: alu_out = alu_in1 - alu_in2
   - Used for: SUB instruction
   - Example: `sub x3, x1, x2` → x3 = x1 - x2

### Comparison Operations
1. **SLT (ALU_SLT = 4'b0010)**
   - Signed less than
   - Performs: alu_out = (signed(alu_in1) < signed(alu_in2)) ? 1 : 0
   - Used for: SLT instruction
   - Example: `slt x3, x1, x2` → x3 = (x1 < x2) ? 1 : 0

2. **SLTU (ALU_SLTU = 4'b0011)**
   - Unsigned less than
   - Performs: alu_out = (alu_in1 < alu_in2) ? 1 : 0
   - Used for: SLTU instruction
   - Example: `sltu x3, x1, x2` → x3 = (unsigned x1 < unsigned x2) ? 1 : 0

### Shift Operations
1. **SLL (ALU_SLL = 4'b0001)**
   - Shift left logical
   - Performs: alu_out = alu_in1 << alu_in2[4:0]
   - Used for: SLL instruction
   - Example: `sll x3, x1, x2` → x3 = x1 << (x2[4:0])

2. **SRL (ALU_SRL = 4'b0101)**
   - Shift right logical
   - Performs: alu_out = alu_in1 >> alu_in2[4:0]
   - Used for: SRL instruction
   - Example: `srl x3, x1, x2` → x3 = x1 >> (x2[4:0])

3. **SRA (ALU_SRA = 4'b1101)**
   - Shift right arithmetic
   - Performs: alu_out = signed(alu_in1) >>> alu_in2[4:0]
   - Used for: SRA instruction
   - Example: `sra x3, x1, x2` → x3 = signed(x1) >>> (x2[4:0])

### Logical Operations
1. **XOR (ALU_XOR = 4'b0100)**
   - Bitwise XOR
   - Performs: alu_out = alu_in1 ^ alu_in2
   - Used for: XOR instruction
   - Example: `xor x3, x1, x2` → x3 = x1 ^ x2

2. **OR (ALU_OR = 4'b0110)**
   - Bitwise OR
   - Performs: alu_out = alu_in1 | alu_in2
   - Used for: OR instruction
   - Example: `or x3, x1, x2` → x3 = x1 | x2

3. **AND (ALU_AND = 4'b0111)**
   - Bitwise AND
   - Performs: alu_out = alu_in1 & alu_in2
   - Used for: AND instruction
   - Example: `and x3, x1, x2` → x3 = x1 & x2

## Implementation Details

### Module Declaration
```verilog
module alu 
import cpu_pkg::*;
(
    input  t_alu_op      alu_op,     // ALU operation select
    input  logic [31:0]  alu_in1,    // First operand
    input  logic [31:0]  alu_in2,    // Second operand
    output logic [31:0]  alu_out     // Result
);
```

### Operation Selection
The ALU uses a case statement to select the appropriate operation based on the alu_op input:
```verilog
always_comb begin
    case (alu_op)
        ALU_ADD:  alu_out = alu_in1 + alu_in2;
        ALU_SUB:  alu_out = alu_in1 - alu_in2;
        ALU_SLT:  alu_out = ($signed(alu_in1) < $signed(alu_in2)) ? 32'd1 : 32'd0;
        ALU_SLTU: alu_out = (alu_in1 < alu_in2) ? 32'd1 : 32'd0;
        ALU_SLL:  alu_out = alu_in1 << alu_in2[4:0];
        ALU_SRL:  alu_out = alu_in1 >> alu_in2[4:0];
        ALU_SRA:  alu_out = $signed(alu_in1) >>> alu_in2[4:0];
        ALU_XOR:  alu_out = alu_in1 ^ alu_in2;
        ALU_OR:   alu_out = alu_in1 | alu_in2;
        ALU_AND:  alu_out = alu_in1 & alu_in2;
        default:  alu_out = 32'd0;
    endcase
end
```

### Key Implementation Features

1. **Combinational Logic**
   - All operations are purely combinational
   - No clock or reset required
   - Results available immediately after input changes

2. **Operation Encoding**
   - Operations encoded in 4 bits
   - Defined as an enum in cpu_pkg.sv
   - Special encoding for SUB (4'b1000) to distinguish from ADD

3. **Signed vs Unsigned Operations**
   - SLT uses signed comparison
   - SLTU uses unsigned comparison
   - SRA uses signed right shift
   - Other operations are bitwise or arithmetic

4. **Shift Operations**
   - Only lower 5 bits of alu_in2 used for shift amount
   - SLL and SRL perform logical shifts
   - SRA performs arithmetic shift (preserves sign)

## Connection to Other Components

### Register File Connection
- **Inputs from RF:**
  - reg_data1 → alu_in1
  - reg_data2 → alu_in2
- **Output to RF:**
  - alu_out → write_d (when selected)

### Program Counter Connection
- **Input to ALU:**
  - pc_out → alu_in1 (for PC-relative operations)
- **Output from ALU:**
  - alu_out → next PC (for branches/jumps)

### Memory Connection
- **Output to Memory:**
  - alu_out → memory address (for load/store)

### Control Unit Connection
- Receives operation select (alu_op) from control unit
- Part of execute stage in pipeline

## Testing

The ALU includes a comprehensive testbench that verifies:
1. All arithmetic operations
2. All logical operations
3. All shift operations
4. Signed and unsigned comparisons
5. Edge cases and special values

Example test cases:
```verilog
// Test ADD
alu_in1 = 32'd10; alu_in2 = 32'd5; alu_op = ALU_ADD;
// Expected: alu_out = 15

// Test SLT (signed)
alu_in1 = -32'd1; alu_in2 = 32'd1; alu_op = ALU_SLT;
// Expected: alu_out = 1

// Test SRA (arithmetic shift)
alu_in1 = -32'd8; alu_in2 = 32'd2; alu_op = ALU_SRA;
// Expected: alu_out = -2
```

## Key Points
1. All operations are combinational (no clock needed)
2. Operations are selected by 4-bit alu_op signal
3. Supports all basic RISC-V arithmetic and logical operations
4. Handles both signed and unsigned operations
5. Shift operations use only lower 5 bits of shift amount
6. Default output is 0 for undefined operations 