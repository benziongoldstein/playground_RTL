// Decoder: Translates RISC-V instructions into control signals and register addresses
// Currently supports R-type (ADD) and I-type (ADDI) instructions
`include "dff_macros.svh"   
module decoder
import cpu_pkg::*;
(
    input logic [31:0] instruction,  // Raw 32b instruction from memory
    output logic [4:0] rs1,          // Source reg 1 (bits 19:15)
    output logic [4:0] rs2,          // Source reg 2 (bits 24:20)
    output logic [4:0] rd,           // Dest reg (bits 11:7)
    output logic [31:0] imm,         // Sign-extended immediate
    output t_ctrl ctrl               // Control signals bundle
);

// Extract register addresses from fixed positions in instruction
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd  = instruction[11:7];

// Generate immediate value: sign-extend for I-type, 0 for R-type
always_comb begin
    if (instruction[6:0] == 7'b0010011) begin // I-type (ADDI)
        imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extend imm[11:0]
    end else begin
        imm = '0; // R-type: no immediate needed
    end
end

// Generate control signals based on instruction opcode
always_comb begin
    // Default control values (safe for unsupported instructions)
    ctrl.alu_op              = ALU_ADD;      // Default to ADD
    ctrl.sel_dmem_wb         = 1'b0;         // Select ALU output
    ctrl.sel_next_pc_alu_out = 1'b0;         // Select PC+4
    ctrl.sel_alu_pc          = 1'b0;         // Select reg for ALU in1
    ctrl.sel_alu_imm         = 1'b0;         // Select reg for ALU in2
    ctrl.reg_wr_en           = 1'b1;         // Enable reg write
    ctrl.mem_byt_en          = 4'b0000;      // No memory access
    ctrl.mem_wr_en           = 1'b0;         // No memory write
    ctrl.sel_wb              = 1'b1;         // Select ALU for writeback
    
    // Set instruction-specific control signals
    case (instruction[6:0])
        7'b0110011: begin // R-type (ADD)
            ctrl.sel_alu_imm = 1'b0; // Use register for ALU input 2
        end
        7'b0010011: begin // I-type (ADDI)
            ctrl.sel_alu_imm = 1'b1; // Use immediate for ALU input 2
        end
        default: begin
            // Keep default values for unsupported instructions
        end
    endcase
end

endmodule
