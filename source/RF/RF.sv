`include "dff_macros.sv"
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

always_comb begin
    // Copy all registers first
    for(int i = 0; i < 32; i++) begin
        next_reg_file[i] = reg_file[i];
    end
    
    // Then handle write if enabled
    if(write_e) begin
        next_reg_file[rd] = write_d;
    end
end

`DFF_1(reg_file, next_reg_file, clk)

assign reg_d1 = reg_file[reg_s1];
assign reg_d2 = reg_file[reg_s2];

endmodule
