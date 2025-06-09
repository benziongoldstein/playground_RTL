// PC: 32b register that holds current instruction address. 32b needed for RV32I's 4GB address space.
// Each instruction is 4B, so PC+4 points to next instruction. Reset to 0 on rst (sync).

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
    assign pc_plus4 = pc_out + 32'd4;
    // Mux to choose between pc_plus4 and alu_out
    assign next_pc = (sel_next_pc_alu_out) ? alu_out : pc_plus4;
    
    // Register for pc_out with reset value
    `DFF_RST(pc_out, next_pc, clk, rst)  // or define RESET_VAL earlier if you prefer

endmodule
