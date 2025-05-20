// ALU: Does math/logic ops (add,sub,shift,etc). Inputs from RF/PC, output to RF/mem/PC.
// No clock needed - pure combinational logic. 4b op code picks which operation to do.

// Arithmetic Logic Unit (ALU) Module
// This module implements the core arithmetic and logical operations for the RISC-V CPU
// Features:
// - Supports all basic RISC-V arithmetic and logical operations
// - 32-bit operands and results
// - Combinational logic (no clock needed)
// - Operations defined in cpu_pkg.sv as t_alu_op enum
`include "dff_macros.svh"    // DFF macros (unused in ALU)

module alu 
import cpu_pkg::*;          // Get ALU op codes
(
    input  t_alu_op      alu_op,     // Operation select (4b)
    input  logic [31:0]  alu_in1,    // First operand
    input  logic [31:0]  alu_in2,    // Second operand
    output logic [31:0]  alu_out     // Result
);

    always_comb begin
        case (alu_op)
            // Arithmetic
            ALU_ADD:  alu_out = alu_in1 + alu_in2;                                // Add
            ALU_SUB:  alu_out = alu_in1 - alu_in2;                                // Subtract

            // Comparison
            ALU_SLT:  alu_out = ($signed(alu_in1) < $signed(alu_in2)) ? 32'd1 : 32'd0; // Signed less-than
            ALU_SLTU: alu_out = (alu_in1 < alu_in2) ? 32'd1 : 32'd0;              // Unsigned less-than

            // Shifts
            ALU_SLL:  alu_out = alu_in1 << alu_in2[4:0];                          // Logical left shift
            ALU_SRL:  alu_out = alu_in1 >> alu_in2[4:0];                          // Logical right shift
            ALU_SRA:  alu_out = $signed(alu_in1) >>> alu_in2[4:0];                // Arithmetic right shift

            // Logical
            ALU_XOR:  alu_out = alu_in1 ^ alu_in2;                                // Bitwise XOR
            ALU_OR:   alu_out = alu_in1 | alu_in2;                                // Bitwise OR
            ALU_AND:  alu_out = alu_in1 & alu_in2;                                // Bitwise AND

            default:  alu_out = 32'd0;                                            // Default to 0
        endcase
    end

endmodule


