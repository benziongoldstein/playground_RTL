// Decoder: Translates RISC-V instructions into control signals and register addresses
// Currently supports R-type (ADD) and I-type (ADDI) instructions
`include "dff_macros.svh"   
module decoder
import cpu_pkg::*;
(
    input logic [31:0] instruction,  // Raw 32b instruction from memory
    input logic branch_cond_out,
    output logic [4:0] rs1,          // Source reg 1 (bits 19:15)
    output logic [4:0] rs2,          // Source reg 2 (bits 24:20)
    output logic [4:0] rd,           // Dest reg (bits 11:7)
    output logic [31:0] imm,         // Sign-extended immediate
    output t_ctrl ctrl               // Control signals bundle

);

// Extract register addresses from fixed positions in instruction
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd  = instruction[11:7];

// Generate immediate value: sign-extend for I-type and S-type, 0 for R-type
always_comb begin
    case (instruction[6:0])
        7'b0010011: begin // I-type (ADDI, etc)
            imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extend imm[11:0]
        end
        7'b0000011: begin // I-type Load
            imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extend imm[11:0]
        end
        7'b0100011: begin // S-type Store
            imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extend imm[11:0] for stores
        end
        7'b1100011: begin // B-type Branch
            imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extend imm[11:0] for branches
        end
        default: begin
            imm = '0; // R-type: no immediate needed
        end
    endcase
end

// Generate control signals based on instruction opcode
always_comb begin
    // Default control values (safe for unsupported instructions)
    ctrl.alu_op              = ALU_ADD;      // Default to ADD
    ctrl.sel_dmem_wb         = 1'b0;         // Select ALU output
    ctrl.sel_next_pc_alu_out = 1'b0;         // Select PC+4
    ctrl.sel_alu_pc          = 1'b0;         // Select reg for ALU in1
    ctrl.sel_alu_imm         = 1'b0;         // Select reg for ALU in2
    ctrl.reg_wr_en           = 1'b1;         // Enable reg write
    ctrl.mem_byt_en          = 4'b0000;      // No memory access
    ctrl.mem_wr_en           = 1'b0;         // No memory write
    ctrl.sel_wb              = 1'b1;         // Select ALU for writeback
    ctrl.sign_ext            = 1'b0;         // No sign extension
    
    // Set instruction-specific control signals
    case (instruction[6:0])
        7'b0110011: begin // R-type 
            ctrl.sel_alu_imm = 1'b0; // Use register for ALU input 2
            case(instruction[14:12]) // funct3
                3'b000: begin
                    if (instruction[31:25] == 7'b0100000)
                        ctrl.alu_op = ALU_SUB; // sub
                    else
                        ctrl.alu_op = ALU_ADD; // add
                end
                3'b001: begin // SLL (Shift Left Logical)
                ctrl.alu_op = ALU_SLL;
                end
                3'b010: begin // SLT (Set Less Than)
                ctrl.alu_op = ALU_SLT;
                end
                3'b011: begin // SLTU (Set Less Than Unsigned)
                    ctrl.alu_op = ALU_SLTU;
                end
                3'b100: begin // XOR
                    ctrl.alu_op = ALU_XOR;
                end
                3'b101: begin // SRL/SRA (Shift Right Logical/Arithmetic)
                    if (instruction[31:25] == 7'b0100000)
                        ctrl.alu_op = ALU_SRA; // Arithmetic shift
                    else
                        ctrl.alu_op = ALU_SRL; // Logical shift
                end
                3'b110: begin // OR
                    ctrl.alu_op = ALU_OR;
                end
                3'b111: begin // AND
                    ctrl.alu_op = ALU_AND;
                end
                default: ctrl.alu_op = ALU_ADD;
            endcase
        end
        7'b0010011: begin // I-type 
            ctrl.sel_alu_imm = 1'b1; // Use immediate for ALU input 2
            case(instruction[14:12]) // funct3 field
                3'b000: begin ctrl.alu_op = ALU_ADD;  end  // ADDI:  Add immediate to register value
                3'b010: begin ctrl.alu_op = ALU_SLT;  end  // SLTI:  Set to 1 if register is less than immediate (signed)
                3'b011: begin ctrl.alu_op = ALU_SLTU; end  // SLTIU: Set to 1 if register is less than immediate (unsigned)
                3'b100: begin ctrl.alu_op = ALU_XOR;  end  // XORI:  XOR register with immediate value
                3'b110: begin ctrl.alu_op = ALU_OR;   end  // ORI:   OR register with immediate value
                3'b111: begin ctrl.alu_op = ALU_AND;  end  // ANDI:  AND register with immediate value
                3'b001: begin ctrl.alu_op = ALU_SLL;  end  // SLLI:  Shift register left by immediate amount
                3'b101: begin 
                    if (instruction[31:25] == 7'b0100000)
                        ctrl.alu_op = ALU_SRA;  // SRAI: Shift register right arithmetic by immediate
                    else
                        ctrl.alu_op = ALU_SRL;  // SRLI: Shift register right logical by immediate
                end
                default: begin ctrl.alu_op = ALU_ADD; end  // Invalid I-type: default to ADD
            endcase
        end
        7'b0000011: begin // I-type Load instructions
            ctrl.sel_alu_imm = 1'b1;  // Use immediate for address calculation
            ctrl.sel_dmem_wb = 1'b1;  // Select memory data for writeback
            ctrl.mem_wr_en   = 1'b0;  // Read from memory
            case(instruction[14:12]) // funct3
                3'b000: begin // LB
                    ctrl.mem_byt_en = 4'b0001;  // Enable byte 0
                    ctrl.sign_ext = 1'b1;
                end
                3'b001: begin // LH
                    ctrl.mem_byt_en = 4'b0011;  // Enable bytes 0,1
                    ctrl.sign_ext = 1'b1;
                end
                3'b010: begin // LW
                    ctrl.mem_byt_en = 4'b1111;  // Enable all bytes
                    ctrl.sign_ext = 1'b1;
                end
                3'b100: begin // LBU
                    ctrl.mem_byt_en = 4'b0001;  // Enable byte 0
                    ctrl.sign_ext = 1'b0;
                end
                3'b101: begin // LHU
                    ctrl.mem_byt_en = 4'b0011;  // Enable bytes 0,1
                    ctrl.sign_ext = 1'b0;
                end
                default: begin
                    ctrl.mem_byt_en = 4'b0000;  // Invalid load
                    ctrl.sign_ext = 1'b0;
                end
            endcase
        end
        7'b0100011: begin // S-type Store instructions
            ctrl.sel_alu_imm = 1'b1;  // Use immediate for address calculation
            ctrl.reg_wr_en   = 1'b0;  // No register write for stores
            ctrl.mem_wr_en   = 1'b1;  // Write to memory
            case(instruction[14:12]) // funct3
                3'b000: begin // SB
                    ctrl.mem_byt_en = 4'b0001;  // Enable byte 0
                end
                3'b001: begin // SH
                    ctrl.mem_byt_en = 4'b0011;  // Enable bytes 0,1
                end
                3'b010: begin // SW
                    ctrl.mem_byt_en = 4'b1111;  // Enable all bytes
                end
                default: begin
                    ctrl.mem_byt_en = 4'b0000;  // Invalid store
                    ctrl.mem_wr_en  = 1'b0;     // Disable write
                end
            endcase
        end
        7'b1100011: begin // B-type Branch instruction
            ctrl.sel_alu_pc = 1'b1;
            ctrl.sel_alu_imm = 1'b1;  // Use immediate for address calculation
            ctrl.reg_wr_en   = 1'b0;  // No register write for branches
            ctrl.mem_wr_en   = 1'b0;  // No memory write for branches
            case(instruction[14:12]) // funct3
                3'b000: begin // BEQ
                    ctrl.branch_cond_op = BRANCH_COND_BEQ;
                end
                3'b001: begin // BNE
                    ctrl.branch_cond_op = BRANCH_COND_BNE;
                end
                3'b100: begin // BLT
                    ctrl.branch_cond_op = BRANCH_COND_BLT;
                end
                3'b101: begin // BGE
                    ctrl.branch_cond_op = BRANCH_COND_BGE;
                end
                3'b110: begin // BLTU   
                    ctrl.branch_cond_op = BRANCH_COND_BLTU;
                end
                3'b111: begin // BGEU
                    ctrl.branch_cond_op = BRANCH_COND_BGEU;
                end
            endcase
            ctrl.sel_next_pc_alu_out = branch_cond_out;

        end
        default: begin
            // Keep default values for unsupported instructions
        end
    endcase
end

endmodule
