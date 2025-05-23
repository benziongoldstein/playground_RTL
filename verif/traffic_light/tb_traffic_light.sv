// tb_traffic_light.sv - Testbench for traffic_light.sv using the same macro-driven style
`timescale 1ns / 1ps

module tb_traffic_light;

    logic clk = 0;
    logic rst = 1;
    logic red, yellow, green;

    // Clock generator
    always #5 clk = ~clk; // 10ns clock period (100 MHz)

    // Instantiate the DUT
    traffic_light #(
        .RED_T(6),
        .REDYLW_T(2),
        .GREEN_T(6),
        .YELLOW_T(2)
    ) dut (
        .clk(clk),
        .rst(rst),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    initial begin
        string vcd_path;
        if (!$value$plusargs("VCD=%s", vcd_path)) vcd_path = "target/traffic_light/traffic_light.vcd";
        $dumpfile(vcd_path);
        $dumpvars(0, tb_traffic_light);

        // Hold reset
        #20 rst = 0;

        // Run simulation for some time
        #200;
        $finish;
    end

endmodule