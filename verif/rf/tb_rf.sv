`timescale 1ns / 1ps

module rf_tb;

    /* DUT signals */
    logic         clk = 0;
    logic [4:0]   reg_s1, reg_s2, rd;
    logic         write_e;
    logic [31:0]  write_d;
    logic [31:0]  reg_d1, reg_d2;

    /* Instantiate Register-File */
    rf uut (
        .clk     (clk),
        .reg_s1  (reg_s1),
        .reg_s2  (reg_s2),
        .rd      (rd),
        .write_e (write_e),
        .write_d (write_d),
        .reg_d1  (reg_d1),
        .reg_d2  (reg_d2)
    );

    /* 10 ns period clock */
    always #5 clk = ~clk;

    initial begin
        $dumpfile("target/rf/rf.vcd");
        $dumpvars(0, rf_tb);

        /* ---------- reset values ---------- */
        {reg_s1, reg_s2, rd} = '0;
        write_e  = 0;
        write_d  = 0;

        /**********  Test 1 : write 42 → x4, read it next cycle  **********/
        @(posedge clk);                // === Edge N : ISSUE WRITE ===
        rd      = 5'd4;                // x4
        write_d = 32'd42;              // value 42
        write_e = 1;                   // asserted before this edge → write occurs now

        @(posedge clk);                // === Edge N+1 : SET READ ADDR ===
        write_e = 0;                   // no more writes
        reg_s1  = 5'd4;                // read x4
        reg_s2  = 5'd0;                // read x0
        #1;                            // δ-delay so combinational mux settles
        if (reg_d1 === 32'd42 && reg_d2 === 32'd0)
            $display("PASS-T1 : x4 = %0d  x0 = %0d", reg_d1, reg_d2);
        else
            $display("FAIL-T1 : x4 = %0d  x0 = %0d", reg_d1, reg_d2);

        /**********  Test 2 : write 99 → x2, read x2 & x4  **********/
        @(posedge clk);                // Edge M : ISSUE WRITE
        rd      = 5'd2;                // x2
        write_d = 32'd99;              // value 99
        write_e = 1;

        @(posedge clk);                // Edge M+1 : SET READ ADDRS
        write_e = 0;
        reg_s1  = 5'd2;                // read x2
        reg_s2  = 5'd4;                // read x4
        #1;
        if (reg_d1 === 32'd99 && reg_d2 === 32'd42)
            $display("PASS-T2 : x2 = %0d  x4 = %0d", reg_d1, reg_d2);
        else
            $display("FAIL-T2 : x2 = %0d  x4 = %0d", reg_d1, reg_d2);

        /* ---------- done ---------- */
        @(posedge clk);
        $display("Simulation completed");
        $finish;
    end
endmodule
