`include "dff_macros.svh"

module pc(
    input  logic        clk,
    input  logic        rst,
    input  logic        sel_next_pc_alu_out,
    input  logic [31:0]  alu_out,

    output logic [31:0]  pc_out,
    output logic [31:0]  pc_plus4   
);

    logic [31:0] next_pc;

    // Compute pc_plus4 = pc_out + 4 (instruction indexing)
    always_comb begin
        pc_plus4 = pc_out + 31'd4;
    end

    // Mux to choose between pc_plus4 and alu_out
    always_comb begin
        next_pc = (sel_next_pc_alu_out) ? alu_out : pc_plus4;
    end

    // Register for pc_out with reset value
    `DFF_RST(pc_out, next_pc, clk, rst)  // or define RESET_VAL earlier if you prefer

endmodule
