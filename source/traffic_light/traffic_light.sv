`include "dff_macros.svh"
// Traffic Light Controller
module traffic_light #(
    parameter int RED_T     = 20,
    parameter int REDYLW_T = 4,
    parameter int GREEN_T   = 20,
    parameter int YELLOW_T  = 4
)(
    input  logic clk,
    input  logic rst,
    output logic red,
    output logic yellow,
    output logic green
);

    // State encoding using localparam
    localparam logic [1:0] S_RED    = 2'd0;
    localparam logic [1:0] S_REDYLW = 2'd1;
    localparam logic [1:0] S_GREEN  = 2'd2;
    localparam logic [1:0] S_YELLOW = 2'd3;

    logic [1:0] state, next_state;
    logic [4:0] timer, next_timer;

    // Instantiate flip-flops using dff macro
    `DFF_RST_VAL(state, next_state, clk, rst, S_RED)
    `DFF_RST_VAL(timer, next_timer, clk, rst, RED_T-1)

    // Next-state logic
    always_comb begin
        case (state)
            S_RED:     next_state = (timer == 0) ? S_REDYLW : S_RED;
            S_REDYLW:  next_state = (timer == 0) ? S_GREEN  : S_REDYLW;
            S_GREEN:   next_state = (timer == 0) ? S_YELLOW : S_GREEN;
            S_YELLOW:  next_state = (timer == 0) ? S_RED    : S_YELLOW;
            default:   next_state = S_RED;
        endcase
    end

    // Timer logic
    always_comb begin
        if (rst) begin
            next_timer = RED_T-1;
        end else if (timer > 0) begin
            next_timer = timer - 1;
        end else begin
            case (state)
                S_RED:     next_timer = REDYLW_T - 1;
                S_REDYLW:  next_timer = GREEN_T  - 1;
                S_GREEN:   next_timer = YELLOW_T - 1;
                S_YELLOW:  next_timer = RED_T    - 1;
                default:   next_timer = RED_T    - 1;
            endcase
        end
    end

    // Output logic
    always_comb begin
        red    = (state == S_RED || state == S_REDYLW);
        yellow = (state == S_REDYLW || state == S_YELLOW);
        green  = (state == S_GREEN);
    end

endmodule
