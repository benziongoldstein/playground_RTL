
`include "dff_macros.svh"   
module decoder
import cpu_pkg::*;
(
    input logic [31:0] instruction,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] imm,
    output t_ctrl ctrl
);

assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd  = instruction[11:7];

// Support for R-type and I-type (ADDI) instructions
// For I-type instructions, extract immediate value with sign extension
always_comb begin
    if (instruction[6:0] == 7'b0010011) begin // I-type (ADDI)
        imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extended immediate
    end else begin
        imm = '0; // For R-type instructions
    end
end

// Control signals for R-type and I-type instructions
always_comb begin
    // Default values
    ctrl.alu_op              = ALU_ADD;
    ctrl.sel_dmem_wb         = 1'b0;
    ctrl.sel_next_pc_alu_out = 1'b0;
    ctrl.sel_alu_pc          = 1'b0;
    ctrl.sel_alu_imm         = 1'b0;
    ctrl.reg_wr_en           = 1'b1;
    ctrl.mem_byt_en          = 4'b0000;
    ctrl.mem_wr_en           = 1'b0;
    ctrl.sel_wb              = 1'b1;
    
    // Instruction-specific settings
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
