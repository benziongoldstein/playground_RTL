
module core_tb;


//clock and reset
logic clk;
logic rst;

// assign clock and reset
initial begin
    clk = 0;
    rst = 1;
    #10 rst = 0;
end
// clock generation
always #5 clk = ~clk;


core core(
    .clk(clk),
    .rst(rst)
);



endmodule