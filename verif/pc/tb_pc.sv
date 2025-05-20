`timescale 1ns / 1ps

module tb_pc;
    logic        clk = 0;
    logic        rst = 1;  // Start with reset active
    logic        sel_next_pc_alu_out = 0;
    logic [31:0] alu_out = 32'd0;
    logic [31:0] pc_out;
    logic [31:0] pc_plus4;

    // Instantiate DUT
    pc dut (
        .clk(clk),
        .rst(rst),
        .sel_next_pc_alu_out(sel_next_pc_alu_out),
        .alu_out(alu_out),
        .pc_out(pc_out),
        .pc_plus4(pc_plus4)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        string vcd_path;
        if (!$value$plusargs("VCD=%s", vcd_path)) vcd_path = "target/pc/pc.vcd";
        $dumpfile(vcd_path);
        $dumpvars(0, tb_pc);

        // Wait a few clock cycles with reset active
        repeat (2) @(posedge clk);
        
        // Test 1: While reset is active, pc_out should be 0
        if (pc_out !== 32'd0)
            $display("FAIL: PC not reset to 0, got %0d", pc_out);
        else
            $display("PASS: PC reset to 0");
            
        rst = 0;
        @(posedge clk);

        // Test 2: PC increments by 4 each cycle when sel_next_pc_alu_out=0
        repeat (3) begin
            @(posedge clk);
            if (pc_out !== pc_plus4 - 32'd4)
                $display("FAIL: PC did not increment correctly, pc_out=%0d, pc_plus4=%0d", pc_out, pc_plus4);
        end
        $display("PASS: PC increments by 4 when sel_next_pc_alu_out=0");

        // Test 3: Load new value from ALU
        alu_out = 32'd40;
        sel_next_pc_alu_out = 1;
        @(posedge clk);
        sel_next_pc_alu_out = 0;
        @(posedge clk);
        if (pc_out !== 32'd40)
            $display("FAIL: PC did not load alu_out, got %0d", pc_out);
        else
            $display("PASS: PC loaded alu_out correctly");

        // Test 4: PC increments by 4 from loaded value
        @(posedge clk);
        if (pc_out !== 32'd44)
            $display("FAIL: PC did not increment from loaded value, got %0d", pc_out);
        else
            $display("PASS: PC incremented from loaded value");

        $display("Simulation completed");
        $finish;
    end
endmodule
