`timescale 1ns / 1ps

module alu_tb;

    // Inputs
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0]  opr;

    // Outputs
    logic [31:0] result;

    // Instantiate the ALU
    alu dut (
        .a(a),
        .b(b),
        .opr(opr),
        .result(result)
    );

    initial begin
        $dumpfile("../target/alu/alu.vcd");
        $dumpvars(0, alu_tb);
        $display("=== ALU Testbench Start ===");
        
        // Test ADD
        a = 32'd10; b = 32'd5; opr = 4'b0000; #1;
        if (result === 32'd15)
            $display("PASS: ADD: %0d + %0d = %0d", a, b, result);
        else
            $display("FAIL: ADD: %0d + %0d = %0d (Expected 15)", a, b, result);

        // Test SUB
        a = 32'd10; b = 32'd5; opr = 4'b1000; #1;
        if (result === 32'd5)
            $display("PASS: SUB: %0d - %0d = %0d", a, b, result);
        else
            $display("FAIL: SUB: %0d - %0d = %0d (Expected 5)", a, b, result);

        // Test SLT (signed less than)
        a = -32'd1; b = 32'd1; opr = 4'b0010; #1;
        if (result === 32'd1)
            $display("PASS: SLT: %0d < %0d = %0d", a, b, result);
        else
            $display("FAIL: SLT: %0d < %0d = %0d (Expected 1)", a, b, result);

        // Test SLTU (unsigned less than)
        a = 32'hFFFFFFFF; b = 32'd1; opr = 4'b0011; #1;
        if (result === 32'd0)
            $display("PASS: SLTU: %0u < %0u = %0d", a, b, result);
        else
            $display("FAIL: SLTU: %0u < %0u = %0d (Expected 0)", a, b, result);

        // Test SLL (shift left logical)
        a = 32'd1; b = 32'd3; opr = 4'b0001; #1;
        if (result === 32'd8)
            $display("PASS: SLL: %0d << %0d = %0d", a, b[4:0], result);
        else
            $display("FAIL: SLL: %0d << %0d = %0d (Expected 8)", a, b[4:0], result);

        // Test SRL (shift right logical)
        a = 32'd8; b = 32'd3; opr = 4'b0101; #1;
        if (result === 32'd1)
            $display("PASS: SRL: %0d >> %0d = %0d", a, b[4:0], result);
        else
            $display("FAIL: SRL: %0d >> %0d = %0d (Expected 1)", a, b[4:0], result);

        // Test SRA (arithmetic right shift)
        a = -32'd8; b = 32'd2; opr = 4'b1101; #1;
        if (result === -32'd2)
            $display("PASS: SRA: %0d >>> %0d = %0d", a, b[4:0], result);
        else
            $display("FAIL: SRA: %0d >>> %0d = %0d (Expected -2)", a, b[4:0], result);

        // Test XOR
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; opr = 4'b0100; #1;
        if (result === 32'hFFFFFFFF)
            $display("PASS: XOR: 0x%h ^ 0x%h = 0x%h", a, b, result);
        else
            $display("FAIL: XOR: 0x%h ^ 0x%h = 0x%h (Expected FFFFFFFF)", a, b, result);

        // Test OR
        a = 32'hF0F00000; b = 32'h0000F0F0; opr = 4'b0110; #1;
        if (result === 32'hF0F0F0F0)
            $display("PASS: OR: 0x%h | 0x%h = 0x%h", a, b, result);
        else
            $display("FAIL: OR: 0x%h | 0x%h = 0x%h (Expected F0F0F0F0)", a, b, result);

        // Test AND
        a = 32'hFF00FF00; b = 32'h0F0F0F0F; opr = 4'b0111; #1;
        if (result === 32'h0F000F00)
            $display("PASS: AND: 0x%h & 0x%h = 0x%h", a, b, result);
        else
            $display("FAIL: AND: 0x%h & 0x%h = 0x%h (Expected 0F000F00)", a, b, result);

        $display("=== ALU Testbench Complete ===");
        $finish;
    end

endmodule
