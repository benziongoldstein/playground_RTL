`timescale 1ns/1ns
module tb;
 // ── Block 1 : Clock & reset ------------------------------------------------
    reg  clk = 0;                     // start clock low
    reg  rst = 1;                     // hold reset high at time 0

    // 100 MHz clock: toggles every 5 ns  (period = 10 ns)
    always #5 clk = ~clk;

    // ── Block 2 : Wires to observe DUT outputs --------------------------------
    wire red;
    wire yellow;
    wire green;

    // ── Block 3 : Instantiate DUT with parameter overrides ---------------------
    traffic_light #(
        .RED_T     (6),   // stay red          6 cycles
        .REDYLW_T  (2),   // red+yellow        2 cycles
        .GREEN_T   (5),   // stay green        5 cycles
        .YELLOW_T  (2)    // yellow            2 cycles
    ) dut (
        .clk   (clk),
        .rst   (rst),
        .red   (red),
        .yellow(yellow),
        .green (green)
    );

    // ── Block 4 : Simulation timeline & waveform dump -------------------------
    initial begin
        // create VCD file for GTKWave
        $dumpfile("traffic.vcd");
        $dumpvars(0, tb);

        // release reset after 15 ns (≈1½ clock cycles)
        #15  rst = 0;

        // run long enough to see several cycles, then stop
        #200 $finish;
    end

endmodule

