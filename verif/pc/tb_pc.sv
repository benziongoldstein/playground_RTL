`timescale 1ns / 1ps

module tb_pc;
    logic clk = 0;
    logic rst = 0;
    logic load = 0;
    logic [4:0] alu_out = 0;
    logic [4:0] pc_out;
    logic [4:0] pc_plus4;

    // Instantiate DUT
    pc dut (
        .clk(clk),
        .rst(rst),
        .load(load),
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

        // Reset
        rst = 1;
        @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Test 1: After reset, pc_out should be 0
        if (pc_out !== 5'd0)
            $display("FAIL: PC not reset to 0, got %0d", pc_out);
        else
            $display("PASS: PC reset to 0");

        // Test 2: PC increments by 1 each cycle when load=0
        repeat (3) begin
            @(posedge clk);
            if (pc_out !== pc_plus4 - 1)
                $display("FAIL: PC did not increment correctly, pc_out=%0d, pc_plus4=%0d", pc_out, pc_plus4);
        end
        $display("PASS: PC increments by 1 when load=0");

        // Test 3: Load new value from ALU
        alu_out = 5'd10;
        load = 1;
        @(posedge clk);
        load = 0;
        @(posedge clk);
        if (pc_out !== 5'd10)
            $display("FAIL: PC did not load alu_out, got %0d", pc_out);
        else
            $display("PASS: PC loaded alu_out correctly");

        // Test 4: PC increments from loaded value
        @(posedge clk);
        if (pc_out !== 5'd11)
            $display("FAIL: PC did not increment from loaded value, got %0d", pc_out);
        else
            $display("PASS: PC incremented from loaded value");

        $display("Simulation completed");
        $finish;
    end
endmodule
