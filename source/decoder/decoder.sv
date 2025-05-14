
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

//WIP - support only R-type instructions
assign imm = '0; //TODO: add support for I-type instructions

//WIP - support only R-type instructions
always_comb begin
    ctrl.alu_op              = ALU_ADD;
    ctrl.sel_dmem_wb         = 1'b0;
    ctrl.sel_next_pc_alu_out = 1'b0;
    ctrl.sel_alu_pc          = 1'b0;
    ctrl.sel_alu_imm         = 1'b0;
    ctrl.reg_wr_en           = 1'b1;
    ctrl.mem_byt_en          = 4'b0000;
    ctrl.mem_wr_en           = 1'b0;
end



endmodule
