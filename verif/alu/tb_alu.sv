`timescale 1ns / 1ps

module alu_tb;
import cpu_pkg::*;

    // Inputs
    t_alu_op     alu_op;
    logic [31:0] alu_in1;
    logic [31:0] alu_in2;

    // Outputs
    logic [31:0] alu_out;

    // Instantiate the ALU
    alu dut (
        .alu_op(alu_op),
        .alu_in1(alu_in1),
        .alu_in2(alu_in2),
        .alu_out(alu_out)
    );

    initial begin
        string vcd_path;
        if (!$value$plusargs("VCD=%s", vcd_path)) vcd_path = "target/alu/alu.vcd";
        $dumpfile(vcd_path);
        $dumpvars(0, alu_tb);
        $display("=== ALU Testbench Start ===");
        
        // Test ADD
        alu_in1 = 32'd10; alu_in2 = 32'd5; alu_op = ALU_ADD; #1;
        if (alu_out === 32'd15)
            $display("PASS: ADD: %0d + %0d = %0d", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: ADD: %0d + %0d = %0d (Expected 15)", alu_in1, alu_in2, alu_out);

        // Test SUB
        alu_in1 = 32'd10; alu_in2 = 32'd5; alu_op = ALU_SUB; #1;
        if (alu_out === 32'd5)
            $display("PASS: SUB: %0d - %0d = %0d", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: SUB: %0d - %0d = %0d (Expected 5)", alu_in1, alu_in2, alu_out);

        // Test SLT (signed less than)
        alu_in1 = -32'd1; alu_in2 = 32'd1; alu_op = ALU_SLT; #1;
        if (alu_out === 32'd1)
            $display("PASS: SLT: %0d < %0d = %0d", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: SLT: %0d < %0d = %0d (Expected 1)", alu_in1, alu_in2, alu_out);

        // Test SLTU (unsigned less than)
        alu_in1 = 32'hFFFFFFFF; alu_in2 = 32'd1; alu_op = ALU_SLTU; #1;
        if (alu_out === 32'd0)
            $display("PASS: SLTU: %0u < %0u = %0d", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: SLTU: %0u < %0u = %0d (Expected 0)", alu_in1, alu_in2, alu_out);

        // Test SLL (shift left logical)
        alu_in1 = 32'd1; alu_in2 = 32'd3; alu_op = ALU_SLL; #1;
        if (alu_out === 32'd8)
            $display("PASS: SLL: %0d << %0d = %0d", alu_in1, alu_in2[4:0], alu_out);
        else
            $display("FAIL: SLL: %0d << %0d = %0d (Expected 8)", alu_in1, alu_in2[4:0], alu_out);

        // Test SRL (shift right logical)
        alu_in1 = 32'd8; alu_in2 = 32'd3; alu_op = ALU_SRL; #1;
        if (alu_out === 32'd1)
            $display("PASS: SRL: %0d >> %0d = %0d", alu_in1, alu_in2[4:0], alu_out);
        else
            $display("FAIL: SRL: %0d >> %0d = %0d (Expected 1)", alu_in1, alu_in2[4:0], alu_out);

        // Test SRA (arithmetic right shift)
        alu_in1 = -32'd8; alu_in2 = 32'd2; alu_op = ALU_SRA; #1;
        if (alu_out === -32'd2)
            $display("PASS: SRA: %0d >>> %0d = %0d", alu_in1, alu_in2[4:0], alu_out);
        else
            $display("FAIL: SRA: %0d >>> %0d = %0d (Expected -2)", alu_in1, alu_in2[4:0], alu_out);

        // Test XOR
        alu_in1 = 32'hF0F0F0F0; alu_in2 = 32'h0F0F0F0F; alu_op = ALU_XOR; #1;
        if (alu_out === 32'hFFFFFFFF)
            $display("PASS: XOR: 0x%h ^ 0x%h = 0x%h", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: XOR: 0x%h ^ 0x%h = 0x%h (Expected FFFFFFFF)", alu_in1, alu_in2, alu_out);

        // Test OR
        alu_in1 = 32'hF0F00000; alu_in2 = 32'h0000F0F0; alu_op = ALU_OR; #1;
        if (alu_out === 32'hF0F0F0F0)
            $display("PASS: OR: 0x%h | 0x%h = 0x%h", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: OR: 0x%h | 0x%h = 0x%h (Expected F0F0F0F0)", alu_in1, alu_in2, alu_out);

        // Test AND
        alu_in1 = 32'hFF00FF00; alu_in2 = 32'h0F0F0F0F; alu_op = ALU_AND; #1;
        if (alu_out === 32'h0F000F00)
            $display("PASS: AND: 0x%h & 0x%h = 0x%h", alu_in1, alu_in2, alu_out);
        else
            $display("FAIL: AND: 0x%h & 0x%h = 0x%h (Expected 0F000F00)", alu_in1, alu_in2, alu_out);

        $display("=== ALU Testbench Complete ===");
        $finish;
    end

endmodule
