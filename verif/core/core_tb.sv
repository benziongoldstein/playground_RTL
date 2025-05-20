module core_tb;

logic clk;
logic rst;

// Clock generation
initial clk = 0;
always #5 clk = ~clk;

// Reset
initial begin
    rst = 1;
    #10 rst = 0;
end

// VCD dump
initial begin
    $dumpfile("target/core/core.vcd");
    $dumpvars(0, core_tb);
end

// Load three instructions into instruction memory
logic [31:0] instruction;
initial begin
    @(negedge rst);
    // ADDI x1, x0, 1
    instruction = 32'b000000000001_00000_000_00001_0010011;
    core.i_mem.mem[0] = instruction[7:0];
    core.i_mem.mem[1] = instruction[15:8];
    core.i_mem.mem[2] = instruction[23:16];
    core.i_mem.mem[3] = instruction[31:24];
    // ADD x2, x1, x0 (x2 = x1 + x0)
    instruction = 32'b0000000_00000_00001_000_00010_0110011;
    core.i_mem.mem[4] = instruction[7:0];
    core.i_mem.mem[5] = instruction[15:8];
    core.i_mem.mem[6] = instruction[23:16];
    core.i_mem.mem[7] = instruction[31:24];
    // ADD x3, x1, x2 (x3 = x1 + x2)
    instruction = 32'b0000000_00010_00001_000_00011_0110011;
    core.i_mem.mem[8] = instruction[7:0];
    core.i_mem.mem[9] = instruction[15:8];
    core.i_mem.mem[10] = instruction[23:16];
    core.i_mem.mem[11] = instruction[31:24];
end

// Run for a few cycles and finish
initial begin
    @(negedge rst);
    repeat (7) @(posedge clk);
    $finish;
end

core core(
    .clk(clk),
    .rst(rst)
);

endmodule