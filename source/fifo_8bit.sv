module fifo_8bit (
    input  logic clk,          // Clock input
    input  logic rst_n,        // Active low reset
    input  logic push,         // Push operation signal
    input  logic pop,          // Pop operation signal
    input  logic data_in,      // 1-bit data input
    output logic data_out,     // 1-bit data output
    output logic full,         // FIFO full indicator
    output logic empty         // FIFO empty indicator
);

    // Internal registers
    logic [2:0] write_ptr;     // Write pointer (3 bits for 8 locations)
    logic [2:0] read_ptr;      // Read pointer (3 bits for 8 locations)
    logic [7:0] fifo_mem;      // 8-bit memory array
    logic [3:0] count;         // Counter to track number of elements

    // Control signals
    logic push_en;
    logic pop_en;

    // Next state logic
    logic [3:0] next_count;
    logic [7:0] next_mem;      // Next state for memory

    // Control logic
    assign push_en = push && !full;
    assign pop_en = pop && !empty;

    // Memory next state logic
    always_comb begin
        next_mem = fifo_mem;  // Default: keep current value
        if (push_en && !full) begin  // Only write if not full
            next_mem[write_ptr] = data_in;
        end
    end

    // Count logic
    assign next_count = (push_en && !pop_en) ? count + 1'b1 :
                       (!push_en && pop_en) ? count - 1'b1 :
                       count;

    // Status logic
    assign full = (count == 4'b1000);
    assign empty = (count == 4'b0000);

    // Output logic
    assign data_out = fifo_mem[read_ptr];

    // Sequential logic using DFF macros
    `DFF_RST_EN(write_ptr, write_ptr + 1'b1, clk, push_en, rst_n, 3'b000)  // Only increments on push
    `DFF_RST_EN(read_ptr, read_ptr + 1'b1, clk, pop_en, rst_n, 3'b000)     // Only increments on pop
    `DFF_RST_EN(count, next_count, clk, push_en || pop_en, rst_n, 4'b0000)
    `DFF_RST_EN(fifo_mem, next_mem, clk, push_en && !full, rst_n, 8'b00000000)

endmodule: fifo_8bit 