
module branch_cond
import cpu_pkg::*;
(
    input logic [31:0] reg_data1,
    input logic [31:0] reg_data2,
    input t_branch_cond_op branch_cond_op,
    output logic branch_cond_out
);

always_comb
begin
    case (branch_cond_op)
        BRANCH_COND_BEQ: branch_cond_out  = (reg_data1 == reg_data2);
        BRANCH_COND_BNE: branch_cond_out  = (reg_data1 != reg_data2);
        BRANCH_COND_BLT: branch_cond_out  = ($signed(reg_data1) < $signed(reg_data2));
        BRANCH_COND_BGE: branch_cond_out  = ($signed(reg_data1) >= $signed(reg_data2));
        BRANCH_COND_BLTU: branch_cond_out = (reg_data1 < reg_data2);
        BRANCH_COND_BGEU: branch_cond_out = (reg_data1 >= reg_data2);
        default: branch_cond_out = 1'b0;
    endcase
end

endmodule