`include "dff_macros.svh"

module mem(
    input logic clk,  
    input logic [31:0] adrs_rd,
    output logic [31:0] rd_data,
    input logic        wr_en,
    input logic [3:0]  byt_en,
    input logic [31:0]  adrs_wr,
    input logic [31:0] wr_data
);

logic [7:0]  [127:0] mem;
logic [7:0]  [127:0] next_mem;


always_comb begin
    next_mem = mem;
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

`DFF(mem, next_mem, clk);

endmodule