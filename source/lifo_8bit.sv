module lifo_8bit (
    input  logic clk,          // Clock input
    input  logic rst_n,        // Active low reset
    input  logic push,         // Push operation signal
    input  logic pop,          // Pop operation signal
    input  logic data_in,      // 1-bit data input
    output logic data_out,     // 1-bit data output
    output logic full,         // Stack full indicator
    output logic empty         // Stack empty indicator
);

    // Internal registers
    logic [2:0] stack_ptr;     // Stack pointer (3 bits for 8 locations)
    logic [7:0] stack_mem;     // 8-bit memory array
    logic [3:0] count;         // Counter to track number of elements

    // Control signals
    logic push_en;
    logic pop_en;

    // Next state logic
    logic [2:0] next_stack_ptr;
    logic [7:0] next_mem;
    logic [3:0] next_count;

    // Control logic
    assign push_en = push && !full;
    assign pop_en = pop && !empty;

    // Stack pointer logic - only change if not full/empty
    assign next_stack_ptr = (push_en && !full) ? stack_ptr + 1'b1 :
                           (pop_en && !empty) ? stack_ptr - 1'b1 :
                           stack_ptr;

    // Memory next state logic
    always_comb begin
        next_mem = stack_mem;  // Default: keep current value
        if (push_en && !full) begin  // Only write if not full
            next_mem[stack_ptr] = data_in;
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
    assign data_out = stack_mem[stack_ptr - 1'b1];

    // Sequential logic using DFF macros
    `DFF_RST_VAL(stack_ptr, next_stack_ptr, clk, rst_n, 3'b000)  // DFF with reset value for stack pointer
    `DFF_RST_EN(count, next_count, clk, push_en || pop_en, rst_n, 4'b0000)
    `DFF_RST_EN(stack_mem, next_mem, clk, push_en && !full, rst_n, 8'b00000000)

endmodule: lifo_8bit 