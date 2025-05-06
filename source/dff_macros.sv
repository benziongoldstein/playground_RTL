`ifndef DFF_MACROS_SV
`define DFF_MACROS_SV

`define DFF(Q, D, CLK, RST, RESET_VAL) \
    always_ff @(posedge CLK or posedge RST) begin \
        if (RST) Q <= RESET_VAL; \
        else     Q <= D; \
    end

`endif
