`timescale 1ns / 1ps

module tb_mem;
    // Clock generation
    logic clk = 0;
    always #5 clk = ~clk;  // 10ns period (100MHz)

    // Memory interface signals
    logic [31:0] adrs_rd;    // Read address
    logic [31:0] adrs_wr;    // Write address
    logic        wr_en;      // Write enable
    logic [3:0]  byt_en;     // Byte enable
    logic [31:0] wr_data;    // Write data
    logic [31:0] rd_data;    // Read data

    // Instantiate DUT
    mem dut (
        .clk(clk),
        .adrs_rd(adrs_rd),
        .adrs_wr(adrs_wr),
        .wr_en(wr_en),
        .byt_en(byt_en),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    initial begin
        string vcd_path;
        if (!$value$plusargs("VCD=%s", vcd_path)) vcd_path = "target/mem/mem.vcd";
        $dumpfile(vcd_path);
        $dumpvars(0, tb_mem);
        $display("=== Memory Testbench Start ===");

        // Initialize signals
        adrs_rd = '0;
        adrs_wr = '0;
        wr_en = 0;
        byt_en = '0;
        wr_data = '0;

        // Wait a few clock cycles
        repeat(2) @(posedge clk);

        // Test 1: Write and read a word (SW instruction)
        adrs_wr = 32'h00;
        wr_data = 32'hAABBCCDD;
        byt_en = 4'b1111;    // Enable all bytes
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        // Read back the word
        adrs_rd = 32'h00;
        @(posedge clk);
        if (rd_data === 32'hAABBCCDD)
            $display("PASS: Word write/read: 0x%h", rd_data);
        else
            $display("FAIL: Word write/read: got 0x%h, expected 0xAABBCCDD", rd_data);

        // Test 2: Write and read a halfword (SH instruction)
        adrs_wr = 32'h04;
        wr_data = 32'h0000EEFF;
        byt_en = 4'b0011;    // Enable lower halfword
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        // Read back the halfword
        adrs_rd = 32'h04;
        @(posedge clk);
        if (rd_data === 32'h0000EEFF)
            $display("PASS: Halfword write/read: 0x%h", rd_data);
        else
            $display("FAIL: Halfword write/read: got 0x%h, expected 0x0000EEFF", rd_data);

        // Test 3: Write and read a byte (SB instruction)
        adrs_wr = 32'h08;
        wr_data = 32'h00000055;
        byt_en = 4'b0001;    // Enable lowest byte
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        // Read back the byte
        adrs_rd = 32'h08;
        @(posedge clk);
        if (rd_data === 32'h00000055)
            $display("PASS: Byte write/read: 0x%h", rd_data);
        else
            $display("FAIL: Byte write/read: got 0x%h, expected 0x00000055", rd_data);

        // Test 4: Write to multiple bytes
        adrs_wr = 32'h0C;
        wr_data = 32'h11223344;
        byt_en = 4'b1010;    // Enable bytes 1 and 3
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        // Read back
        adrs_rd = 32'h0C;
        @(posedge clk);
        if (rd_data === 32'h11003300)
            $display("PASS: Multiple byte write/read: 0x%h", rd_data);
        else
            $display("FAIL: Multiple byte write/read: got 0x%h, expected 0x11003300", rd_data);

        // Test 5: Read from unwritten location
        adrs_rd = 32'h10;
        @(posedge clk);
        if (rd_data === 32'h00000000)
            $display("PASS: Read from unwritten location: 0x%h", rd_data);
        else
            $display("FAIL: Read from unwritten location: got 0x%h, expected 0x00000000", rd_data);

        $display("=== Memory Testbench Complete ===");
        $finish;
    end

endmodule 