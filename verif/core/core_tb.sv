module core_tb;

//clock and reset
logic clk;
logic rst;

// Simulation control
int cycles;
localparam int MAX_CYCLES = 100;

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

// Load instruction memory from compiled program
initial begin
    string mem_file;
    int fd, status;
    bit [7:0] memory[0:4095]; // Temporary memory for loading
    bit [31:0] address;
    
    // Initialize memory to zeros
    for (int i = 0; i < 128; i++) begin
        core.i_mem.mem[i] = 8'h00;
    end
    
    // Open memory file and read content
    mem_file = "verif/core/inst_mem.sv";
    $display("Loading instruction memory from %s...", mem_file);
    
    // Use system task to load memory from inst_mem.sv
    fd = $fopen(mem_file, "r");
    if (fd) begin
        $display("Successfully opened memory file");
        // The $readmemh function will automatically handle the @address directives
        $readmemh(mem_file, core.i_mem.mem);
        $fclose(fd);
    end else begin
        $display("Error: Could not open memory file %s", mem_file);
        $finish;
    end
    
    // Debug: Display the first few instructions loaded
    $display("First few memory bytes after loading:");
    for (int i = 0; i < 16; i += 4) begin
        $display("mem[%0d:%0d] = %02h %02h %02h %02h (as instruction: %08h)", 
                i, i+3, 
                core.i_mem.mem[i], 
                core.i_mem.mem[i+1], 
                core.i_mem.mem[i+2], 
                core.i_mem.mem[i+3],
                {core.i_mem.mem[i+3], core.i_mem.mem[i+2], core.i_mem.mem[i+1], core.i_mem.mem[i]});
    end
    
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
        for (int i = 1; i <= 31; i++) begin
            if (core.rf.write_e && core.rf.rd == i)
                $display("Time %0t: Register x%0d updated to %0h", $time, i, core.rf.write_d);
        end
    end
end

// Add instruction monitor
always @(posedge clk) begin
    if (!rst) begin
        $display("Time %0t: PC=%08h, Instruction=%08h", 
                 $time, 
                 core.pc_out, 
                 {core.i_mem.mem[core.pc_out+3], 
                  core.i_mem.mem[core.pc_out+2], 
                  core.i_mem.mem[core.pc_out+1], 
                  core.i_mem.mem[core.pc_out]});
    end
end

core core(
    .clk(clk),
    .rst(rst)
);

endmodule