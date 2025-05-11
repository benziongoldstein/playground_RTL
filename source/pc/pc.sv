`include "dff_macros.svh"

module pc(
    input  logic        clk,
    input  logic        rst,
    input  logic        load,
    input  logic [4:0]  alu_out,

    output logic [4:0]  pc_out,
    output logic [4:0]  pc_plus4   
);

    logic [4:0] next_pc;

    // Compute pc_plus4 = pc_out + 1 (instruction indexing)
    always_comb begin
        pc_plus4 = pc_out + 5'd1;
    end

    // Mux to choose between pc_plus4 and alu_out
    always_comb begin
        next_pc = (load) ? alu_out : pc_plus4;
    end

    // Register for pc_out with reset value
    `DFF(pc_out, next_pc, clk, rst, 5'd0)  // or define RESET_VAL earlier if you prefer

endmodule
