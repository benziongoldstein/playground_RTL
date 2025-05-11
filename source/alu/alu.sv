module alu (
    input  logic [3:0]   opr,     // ALU operation select
    input  logic [31:0]  a,       // operand A
    input  logic [31:0]  b,       // operand B

    output logic [31:0]  result   // result (renamed from "output")
);

// Enum for ALU operation types
// ALU operation codes — values follow RISC-V convention.
// Note: SUB is 4'b1000 to reflect funct7=1 (used to distinguish SUB from ADD).
    typedef enum logic [3:0] {
        alu_add  = 4'b0000, // Addition:        result = a + b
        alu_sub  = 4'b1000, // Subtraction:     result = a - b
        alu_slt  = 4'b0010, // Set if less than (signed): result = (a < b) ? 1 : 0
        alu_sltu = 4'b0011, // Set if less than (unsigned)
        alu_sll  = 4'b0001, // Shift left logical: result = a << b[4:0]
        alu_srl  = 4'b0101, // Shift right logical: result = a >> b[4:0]
        alu_sra  = 4'b1101, // Shift right arithmetic: result = signed(a) >>> b[4:0]
        alu_xor  = 4'b0100, // Bitwise XOR:     result = a ^ b
        alu_or   = 4'b0110, // Bitwise OR:      result = a | b
        alu_and  = 4'b0111  // Bitwise AND:     result = a & b
    } t_alu_op;

// Main combinational ALU logic
    always_comb begin
        case (t_alu_op'(opr))  // Cast opr (logic[3:0]) into the t_alu_op enum
            alu_add:  result = a + b;                                // Add
            alu_sub:  result = a - b;                                // Subtract
            alu_slt:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // Signed less-than
            alu_sltu: result = (a < b) ? 32'd1 : 32'd0;              // Unsigned less-than
            alu_sll:  result = a << b[4:0];                          // Logical left shift
            alu_srl:  result = a >> b[4:0];                          // Logical right shift
            alu_sra:  result = $signed(a) >>> b[4:0];                // Arithmetic right shift
            alu_xor:  result = a ^ b;                                // Bitwise XOR
            alu_or:   result = a | b;                                // Bitwise OR
            alu_and:  result = a & b;                                // Bitwise AND
            default:  result = 32'd0;                                // Default to 0
        endcase
    end

endmodule


