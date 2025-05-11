`ifndef DFF_MACROS_SVH
`define DFF_MACROS_SVH


`define DFF(Q, D, CLK, RST, RESET_VAL) \
    always_ff @(posedge CLK or posedge RST) begin \
        if (RST) Q <= RESET_VAL; \
        else     Q <= D; \
    end

`define DFF_EN(q, in, clk, en) \
    always_ff @(posedge clk) begin \
        if (en) q <= in; \
    end

`endif
