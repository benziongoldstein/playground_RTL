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
    
    @(negedge rst);
    @(posedge clk);
end

//check if ebreak is hit
always_comb begin
    if (core.instruction == 32'h00100073) begin
        $display("EBREAK hit at time %0t", $time);
        $finish;
    end
end

// Cycle counter and simulation termination
always @(posedge clk) begin
    cycles <= cycles + 1;
    if (cycles >= MAX_CYCLES) begin
        $display("Simulation reached maximum cycle count of %0d", MAX_CYCLES);
        $finish;
    end
end

// Monitor for instruction fetch and register file changes

always @(posedge clk) begin
    if (!rst) begin
        $write("Time %0t: PC=%08h, Instruction=%08h", 
               $time, 
               core.pc_out,
               {core.i_mem.mem[core.pc_out+3],
                core.i_mem.mem[core.pc_out+2],
                core.i_mem.mem[core.pc_out+1],
                core.i_mem.mem[core.pc_out]});
                
        

        if (core.rf.write_e) begin
            $write(", Register x%0d = %08h", core.rf.rd, core.rf.write_d);
        

        if(core.instruction[6:0] == 7'b0000011) begin
            if((core.ctrl.mem_byt_en == 4'b0001) && (core.ctrl.sign_ext == 1'b1)) begin
                $write(", LB  mem[%08h]", core.alu_out);
            end else if(core.ctrl.mem_byt_en == 4'b0011) begin
                $write(", LH  mem[%08h]", core.alu_out);
            end else if(core.ctrl.mem_byt_en == 4'b1111) begin
                $write(", LW  mem[%08h]", core.alu_out);
            end
            else if((core.ctrl.mem_byt_en == 4'b0001) && (core.ctrl.sign_ext == 1'b0)) begin
                $write(", LBU mem[%08h]", core.alu_out);
            end else if(core.ctrl.mem_byt_en == 4'b0011) begin
                $write(", LHU mem[%08h]", core.alu_out);
            end else if(core.ctrl.mem_byt_en == 4'b1111) begin
                $write(", LW  mem[%08h]", core.alu_out);
            end
        end
        
        end else if(core.ctrl.mem_wr_en) begin
            if(core.ctrl.mem_byt_en == 4'b0001) begin
                $write(",                         SB  mem[%08h] = %h", core.alu_out, core.reg_data2[7:0]);
            end else if(core.ctrl.mem_byt_en == 4'b0011) begin
                $write(",                         SH  mem[%08h] = %h", core.alu_out, core.reg_data2[15:0]);
            end else if(core.ctrl.mem_byt_en == 4'b1111) begin
                $write(",                         SW  mem[%08h] = %08h", core.alu_out, core.reg_data2);
            end
        end else begin
            $display("");
        end
    end
    $display("");
end

core core(
    .clk(clk),
    .rst(rst)
);

endmodule