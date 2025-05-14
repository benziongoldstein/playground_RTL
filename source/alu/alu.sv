
module alu 
import cpu_pkg::*;
(
    input  t_alu_op      alu_op,     // ALU operation select
    input  logic [31:0]  alu_in1,       // operand A
    input  logic [31:0]  alu_in2,       // operand B

    output logic [31:0]  alu_out      // alu_out     (renamed from "output")
);
// Main combinational ALU logic
    always_comb begin
        case (alu_op)  // Cast opr (logic[3:0]) into the t_alu_op enum
            ALU_ADD:  alu_out     = alu_in1 + alu_in2;                                // Add
            ALU_SUB:  alu_out     = alu_in1 - alu_in2;                                // Subtract
            ALU_SLT:  alu_out     = ($signed(alu_in1) < $signed(alu_in2)) ? 32'd1 : 32'd0; // Signed less-than
            ALU_SLTU: alu_out     = (alu_in1 < alu_in2) ? 32'd1 : 32'd0;              // Unsigned less-than
            ALU_SLL:  alu_out     = alu_in1 << alu_in2[4:0];                          // Logical left shift
            ALU_SRL:  alu_out     = alu_in1 >> alu_in2[4:0];                          // Logical right shift
            ALU_SRA:  alu_out     = $signed(alu_in1) >>> alu_in2[4:0];                // Arithmetic right shift
            ALU_XOR:  alu_out     = alu_in1 ^ alu_in2;                                // Bitwise XOR
            ALU_OR:   alu_out     = alu_in1 | alu_in2;                                // Bitwise OR
            ALU_AND:  alu_out     = alu_in1 & alu_in2;                                // Bitwise AND
            default:  alu_out     = 32'd0;                                // Default to 0
        endcase
    end

endmodule


