`include "dff_macros.svh"
module RF(
input logic         clk,
input logic [4:0]  reg_s1,
input logic [4:0]  reg_s2,
input logic [4:0]   rd,
input logic         write_e,
input logic [31:0]  write_d,

output logic [31:0] reg_d1,
output logic [31:0] reg_d2
);

logic [31:0] reg_file  [31:0];
logic [31:0] next_reg_file  [31:0];

`DFF_EN(reg_file[rd], write_d, clk, write_e)

assign reg_d1 = reg_file[reg_s1];
assign reg_d2 = reg_file[reg_s2];

endmodule
