module core_tb;

//clock and reset
logic clk;
logic rst;

// Simulation control
int cycles;
localparam int MAX_CYCLES = 50;

// assign clock and reset
initial begin
    // Setup VCD file for waveform dumping
    string vcd_path;
    if (!$value$plusargs("VCD=%s", vcd_path)) vcd_path = "target/core/core.vcd";
    $dumpfile(vcd_path);
    $dumpvars(0, core_tb);
    
    clk = 0;
    rst = 1;
    cycles = 0;
    #10 rst = 0;
end
// clock generation
always #5 clk = ~clk;

// Force instruction memory values
// R-type ADD instruction format: 0000000_rs2[4:0]_rs1[4:0]_000_rd[4:0]_0110011
logic [31:0] instruction;
initial begin
    // Wait for reset to complete

    // Initialize memory with instructions
    // ADDI x1, x0, 1    ; x1 = 1
    instruction = 32'b000000000001_00000_000_00001_0010011;
    core.i_mem.mem[0] = instruction[7:0];
    core.i_mem.mem[1] = instruction[15:8];
    core.i_mem.mem[2] = instruction[23:16];
    core.i_mem.mem[3] = instruction[31:24];

    // ADDI x2, x0, 2    ; x2 = 2
    instruction = 32'b000000000010_00000_000_00010_0010011;
    core.i_mem.mem[4] = instruction[7:0];
    core.i_mem.mem[5] = instruction[15:8];
    core.i_mem.mem[6] = instruction[23:16];
    core.i_mem.mem[7] = instruction[31:24];

    // ADD x3, x1, x2    ; x3 = x1 + x2
    instruction = 32'b0000000_00010_00001_000_00011_0110011;
    core.i_mem.mem[8] = instruction[7:0];
    core.i_mem.mem[9] = instruction[15:8];
    core.i_mem.mem[10] = instruction[23:16];
    core.i_mem.mem[11] = instruction[31:24];

    // ADD x4, x1, x3    ; x4 = x1 + x3
    instruction = 32'b0000000_00011_00001_000_00100_0110011;
    core.i_mem.mem[12] = instruction[7:0];
    core.i_mem.mem[13] = instruction[15:8];
    core.i_mem.mem[14] = instruction[23:16];
    core.i_mem.mem[15] = instruction[31:24];

    // ADD x5, x2, x4    ; x5 = x2 + x4
    instruction = 32'b0000000_00100_00010_000_00101_0110011;
    core.i_mem.mem[16] = instruction[7:0];
    core.i_mem.mem[17] = instruction[15:8];
    core.i_mem.mem[18] = instruction[23:16];
    core.i_mem.mem[19] = instruction[31:24];

    // ADD x6, x3, x5    ; x6 = x3 + x5
    instruction = 32'b0000000_00101_00011_000_00110_0110011;
    core.i_mem.mem[20] = instruction[7:0];
    core.i_mem.mem[21] = instruction[15:8];
    core.i_mem.mem[22] = instruction[23:16];
    core.i_mem.mem[23] = instruction[31:24];

    // ADD x7, x4, x6    ; x7 = x4 + x6
    instruction = 32'b0000000_00110_00100_000_00111_0110011;
    core.i_mem.mem[24] = instruction[7:0];
    core.i_mem.mem[25] = instruction[15:8];
    core.i_mem.mem[26] = instruction[23:16];
    core.i_mem.mem[27] = instruction[31:24];

    @(negedge rst);
    @(posedge clk);
end

// Cycle counter and simulation termination
always @(posedge clk) begin
    cycles <= cycles + 1;
    if (cycles >= MAX_CYCLES) begin
        $display("Simulation reached maximum cycle count of %0d", MAX_CYCLES);
        $finish;
    end
end

// Monitor for register file changes
always @(posedge clk) begin
    if (!rst) begin
        for (int i = 1; i <= 8; i++) begin
            if (core.rf.write_e && core.rf.rd == i)
                $display("Time %0t: Register x%0d updated to %0h", $time, i, core.rf.write_d);
        end
    end
end

core core(
    .clk(clk),
    .rst(rst)
);

endmodule