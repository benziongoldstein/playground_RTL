`ifndef DFF_MACROS_SV
`define DFF_MACROS_SV

`define DFF(Q, D, CLK, RST, RESET_VAL) \
    always_ff @(posedge CLK or posedge RST) begin \
        if (RST) Q <= RESET_VAL; \
        else     Q <= D; \
    end

`define DFF_1(state, next_state, CLK) \
    always_ff @(posedge CLK) begin \
        for(int i=0; i<32; i++) begin \
            state[i] <= next_state[i]; \
        end \
    end

`endif
