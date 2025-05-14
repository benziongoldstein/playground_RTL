`include "dff_macros.svh"
module rf(
input logic         clk,
input logic [4:0]   rs1,
input logic [4:0]   rs2,
input logic [4:0]   rd,
input logic         write_e,
input logic [31:0]  write_d,

output logic [31:0] reg_data1,
output logic [31:0] reg_data2
);

logic [31:0] reg_file  [31:0];

`DFF_EN(reg_file[rd], write_d, clk, write_e)

assign reg_data1 = (rs1 == 5'b0) ? 32'b0 : reg_file[rs1];
assign reg_data2 = (rs2 == 5'b0) ? 32'b0 : reg_file[rs2];

endmodule
