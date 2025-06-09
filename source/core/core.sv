// core.sv
// the core wil implement the 5 stages of the RISC-V pipeline
// 1. IF: Instruction Fetch
// 2. ID: Instruction Decode
// 3. EX: Execute
// 4. MEM: Memory Access
// 5. WB: Write Back

`include "dff_macros.svh"

module core
import cpu_pkg::*;
(
    input logic clk,
    input logic rst
);

logic [31:0] pc_out;
logic [31:0] pc_plus4;
logic [31:0] alu_out;
logic [31:0] mem_rd_data;
logic [31:0] reg_wr_data;
logic [31:0] wb_data;
logic [31:0] instruction;
logic [4:0]  rs1;
logic [4:0]  rs2;
logic [4:0]  rd;
logic [31:0] imm;
logic [31:0] reg_data1;
logic [31:0] reg_data2;
logic [31:0] alu_in1;
logic [31:0] alu_in2;

t_ctrl ctrl;


//fetch stage
pc pc(
    .clk                (clk),
    .rst                (rst),
    .sel_next_pc_alu_out(ctrl.sel_next_pc_alu_out),
    .alu_out            (alu_out),
    .pc_out             (pc_out),
    .pc_plus4           (pc_plus4)
);

mem i_mem(
    .clk          (clk),
    .adrs_rd      (pc_out),
    .rd_data      (instruction),
    .wr_en        (1'b0),
    .byt_en       (4'b1111),
    .sign_ext     (1'b0),
    .adrs_wr      (32'b0),
    .wr_data      (32'b0)
);

//decode stage
decoder decoder(
    .instruction    (instruction),// input
    .rs1            (rs1),        // output
    .rs2            (rs2),        // output
    .rd             (rd),         // output
    .imm            (imm),        // output
    .ctrl           (ctrl)        // output
);

assign reg_wr_data = ctrl.sel_wb ? wb_data : pc_plus4;
rf rf(
    .clk        (clk),              // input
    .rs1        (rs1),              // input
    .rs2        (rs2),              // input
    .rd         (rd),               // input
    .write_e    (ctrl.reg_wr_en),   // input
    .write_d    (reg_wr_data),          // input
    .reg_data1  (reg_data1),        // output
    .reg_data2  (reg_data2)         // output
);



assign alu_in1 = ctrl.sel_alu_pc  ? pc_out : reg_data1;
assign alu_in2 = ctrl.sel_alu_imm ? imm    : reg_data2;
//execute stage
alu alu(
    .alu_op    (ctrl.alu_op),   // input
    .alu_in1   (alu_in1),   // input
    .alu_in2   (alu_in2),   // input
    .alu_out   (alu_out)    // output
);

//memory stage
mem d_mem(
    .clk          (clk),
    .adrs_rd      (alu_out),
    .rd_data      (mem_rd_data),
    .wr_en        (ctrl.mem_wr_en),
    .byt_en       (ctrl.mem_byt_en),
    .sign_ext     (ctrl.sign_ext),
    .adrs_wr      (alu_out),
    .wr_data      (reg_data2)
);

assign wb_data = ctrl.sel_dmem_wb ? mem_rd_data : alu_out;

endmodule