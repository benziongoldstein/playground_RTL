// Memory: 1024B array that can be read/written in different sizes (byte/halfword/word)
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
    input  logic        clk,        // Clock
    input  logic [31:0] adrs_rd,    // Read address
    output logic [31:0] rd_data,    // Read data output
    input  logic        wr_en,      // Write enable (1 = write, 0 = read)
    input  logic [3:0]  byt_en,     // Byte enables for write
    input  logic        sign_ext,   // Sign extension enable
    input  logic [31:0] adrs_wr,    // Write address
    input  logic [31:0] wr_data     // Data to write
);

logic [7:0] mem [1023:0];           // 1 KB memory array (8-bit wide)
logic [7:0] next_mem [1023:0];      // Next state memory (for clocked updates)



// -----------------------
// Memory Read Logic
// -----------------------
always_comb begin
    rd_data[7:0]   = byt_en[0]  ? mem[adrs_rd]     : 8'b0;
    rd_data[15:8]  = byt_en[1]  ? mem[adrs_rd + 1] :      
                     sign_ext   ? {8{rd_data[7]}}  : 8'b0;
    rd_data[23:16] = byt_en[2]  ? mem[adrs_rd + 2] : 
                     sign_ext   ? {8{rd_data[15]}} : 8'b0;
    rd_data[31:24] = byt_en[3]  ? mem[adrs_rd + 3] : 
                     sign_ext   ? {8{rd_data[23]}} : 8'b0;
end

// -----------------------
// Memory Write Logic
// -----------------------


always_comb begin
    for (int i = 0; i < 1024; i++) begin
        next_mem[i] = mem[i]; // Default: keep old values
    end
    if (wr_en) begin
        if (byt_en[0]) next_mem[adrs_wr + 0] = wr_data[7:0];    // Write byte 0
        if (byt_en[1]) next_mem[adrs_wr + 1] = wr_data[15:8];   // Write byte 1
        if (byt_en[2]) next_mem[adrs_wr + 2] = wr_data[23:16];  // Write byte 2
        if (byt_en[3]) next_mem[adrs_wr + 3] = wr_data[31:24];  // Write byte 3
    end
end

// -----------------------
// Memory Clocked Update
// -----------------------
// Use macro to update memory array on clock edge
`DFF_MEM(mem, next_mem, clk)

endmodule

