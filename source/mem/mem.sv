// Memory: 128B array that can be read/written in different sizes (byte/halfword/word)
// byt_en[3:0] controls which bytes to write:
//   byt_en[0] = 1: write byte 0 (bits 7:0)   - for byte writes
//   byt_en[1] = 1: write byte 1 (bits 15:8)  - for halfword writes
//   byt_en[2] = 1: write byte 2 (bits 23:16) - for word writes
//   byt_en[3] = 1: write byte 3 (bits 31:24) - for word writes
// Examples:
//   byt_en = 4'b0001: write only byte 0 (8b)
//   byt_en = 4'b0011: write bytes 0,1 (16b)
//   byt_en = 4'b1111: write all bytes (32b)

`include "dff_macros.svh"

module mem(
    input logic clk,  
    input logic [31:0] adrs_rd,    // Read address (word-aligned)
    output logic [31:0] rd_data,   // Read data (always 32b)
    input logic        wr_en,      // 1=write, 0=read
    input logic [3:0]  byt_en,     // Which bytes to write
    input logic [31:0] adrs_wr,    // Write address (word-aligned)
    input logic [31:0] wr_data     // Data to write
);

logic [7:0] mem [127:0];
logic [7:0] next_mem [127:0];

// Initialize memory to zero for simulation
initial begin
    for (int i = 0; i < 128; i++) begin
        mem[i] = 8'h00;
    end
end

always_comb begin
    for (int i = 0; i < 128; i++) begin
        next_mem[i] = mem[i];
    end
    if (wr_en) begin
        next_mem[adrs_wr+0] = byt_en[0] ? wr_data[7:0]   : mem[adrs_wr+0];
        next_mem[adrs_wr+1] = byt_en[1] ? wr_data[15:8]  : mem[adrs_wr+1];
        next_mem[adrs_wr+2] = byt_en[2] ? wr_data[23:16] : mem[adrs_wr+2];
        next_mem[adrs_wr+3] = byt_en[3] ? wr_data[31:24] : mem[adrs_wr+3];
    end
end

assign rd_data = {mem[adrs_rd+3], 
                 mem[adrs_rd+2], 
                 mem[adrs_rd+1], 
                 mem[adrs_rd+0]};

// Use DFF_MEM macro to update memory on clock edge
`DFF_MEM(mem, next_mem, clk)

endmodule