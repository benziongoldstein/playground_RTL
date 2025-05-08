`timescale 1ns / 1ps

module RF_tb;

    // Inputs
    logic clk;
    logic [4:0] reg_s1;
    logic [4:0] reg_s2;
    logic [4:0] rd;
    logic write_e;
    logic [31:0] write_d;

    // Outputs
    logic [31:0] reg_d1;
    logic [31:0] reg_d2;

    // Instantiate the DUT (Device Under Test)
    RF uut (
        .clk(clk),
        .reg_s1(reg_s1),
        .reg_s2(reg_s2),
        .rd(rd),
        .write_e(write_e),
        .write_d(write_d),
        .reg_d1(reg_d1),
        .reg_d2(reg_d2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // === Waveform setup ===
        $dumpfile("../target/RF/RF.vcd");
        $dumpvars(0, RF_tb);

        // === Initialize ===
        clk = 0;
        reg_s1 = 0;
        reg_s2 = 0;
        rd = 0;
        write_e = 0;
        write_d = 0;

        // === Test Case 1: Write 42 to x4 ===
        #10;
        rd = 5'd4;
        write_d = 32'd42;
        write_e = 1;
        #10;
        write_e = 0;

        // === Test Case 2: Read x4 into reg_d1 ===
        reg_s1 = 5'd4;
        reg_s2 = 5'd0;
        #10;
        if (reg_d1 === 32'd42)
            $display("PASS: Read x4 = %0d, expected 42", reg_d1);
        else
            $display("FAIL: Read x4 = %0d, expected 42", reg_d1);
        if (reg_d2 === 32'd0)
            $display("PASS: Read x0 = %0d (should be 0)", reg_d2);
        else
            $display("FAIL: Read x0 = %0d (should be 0)", reg_d2);

        // === Test Case 3: Write 99 to x2 ===
        rd = 5'd2;
        write_d = 32'd99;
        write_e = 1;
        #10;
        write_e = 0;

        // === Test Case 4: Read both x2 and x4 ===
        reg_s1 = 5'd2;
        reg_s2 = 5'd4;
        #10;
        if (reg_d1 === 32'd99)
            $display("PASS: Read x2 = %0d, expected 99", reg_d1);
        else
            $display("FAIL: Read x2 = %0d, expected 99", reg_d1);
        if (reg_d2 === 32'd42)
            $display("PASS: Read x4 = %0d, expected 42", reg_d2);
        else
            $display("FAIL: Read x4 = %0d, expected 42", reg_d2);

        // === Test Case 5: Write to same register being read ===
        rd = 5'd4;
        reg_s1 = 5'd4;
        write_d = 32'd123;
        write_e = 1;
        #10;
        write_e = 0;
        #10;
        if (reg_d1 === 32'd123)
            $display("PASS: Read x4 = %0d, expected 123", reg_d1);
        else
            $display("FAIL: Read x4 = %0d, expected 123", reg_d1);

        // === End simulation ===
        #10;
        $display("Simulation completed");
        $finish;
    end

endmodule
