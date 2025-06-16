`ifndef DFF_MACROS_SVH
`define DFF_MACROS_SVH


`define DFF(Q, D, CLK) \
    always_ff @(posedge CLK) begin \
        Q <= D; \
    end


`define DFF_RST(Q, D, CLK, RST) \
    always_ff @(posedge CLK or posedge RST) begin \
        if (RST) Q <= '0; \
        else     Q <= D; \
    end



`define DFF_RST_VAL(Q, D, CLK, RST, RESET_VAL) \
    always_ff @(posedge CLK or posedge RST) begin \
        if (RST) Q <= RESET_VAL; \
        else     Q <= D; \
    end

    
`define DFF_EN(q, in, clk, en) \
    always_ff @(posedge clk) begin \
        if (en) q <= in; \
    end

// Macro for memory array DFF
`define DFF_MEM(MEM, NEXT_MEM, CLK) \
    always_ff @(posedge CLK) begin \
        for (int i = 0; i < $size(MEM); i++) begin \
            MEM[i] <= NEXT_MEM[i]; \
        end \
    end

// Macro for DFF with both reset and enable
`define DFF_RST_EN(OUT, IN, CLK, EN, RST, RST_VAL) \
    always_ff @(posedge CLK) begin \
        if (RST) OUT <= RST_VAL; \
        else if (EN) OUT <= IN; \
    end


`endif
