// traffic_light.v - Verilog-2005 compatible version for Yosys

module traffic_light #(
    parameter RED_T     = 20,
    parameter REDYLW_T = 4,
    parameter GREEN_T   = 20,
    parameter YELLOW_T  = 4
)(
    input clk,
    input rst,
    output logic red,
    output logic yellow,
    output logic green
);

// State encoding
parameter S_RED    = 2'd0;
parameter S_REDYLW = 2'd1;
parameter S_GREEN  = 2'd2;
parameter S_YELLOW = 2'd3;

logic [1:0] state, next_state;
logic [4:0] timer; // wide enough for delay values

// State register with reset
always @(posedge clk) begin
    if (rst) begin
        state <= S_RED;
        timer <= RED_T;
    end else begin
        state <= next_state;
        if (timer > 0)
            timer <= timer - 1;
        else begin
            case (state)
                S_RED:    timer <= REDYLW_T-1;
                S_REDYLW: timer <= GREEN_T-1;
                S_GREEN:  timer <= YELLOW_T-1;
                S_YELLOW: timer <= RED_T-1;
                default:  timer <= RED_T-1;
            endcase
        end
    end
end

// Next state logic
always @(*) begin
    case (state)
        S_RED:    next_state = (timer == 0) ? S_REDYLW : S_RED;
        S_REDYLW: next_state = (timer == 0) ? S_GREEN  : S_REDYLW;
        S_GREEN:  next_state = (timer == 0) ? S_YELLOW : S_GREEN;
        S_YELLOW: next_state = (timer == 0) ? S_RED    : S_YELLOW;
        default:  next_state = S_RED;
    endcase
end

// Output logic
always @(*) begin
    red    = (state == S_RED || state == S_REDYLW);
    yellow = (state == S_REDYLW || state == S_YELLOW);
    green  = (state == S_GREEN);
end

endmodule
