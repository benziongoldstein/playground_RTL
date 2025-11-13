module core_tb;
import cpu_pkg::*;

//clock and reset
logic clk;
logic rst;

// Simulation control
int cycles;
localparam int MAX_CYCLES = 100;

// Arrays to store instruction history
localparam MAX_INSTRUCTIONS = 100;
logic [31:0] pc_history [MAX_INSTRUCTIONS];
logic [31:0] inst_history [MAX_INSTRUCTIONS];
string inst_names [MAX_INSTRUCTIONS];
logic pc_plus4_history [MAX_INSTRUCTIONS];
logic pc_im_history [MAX_INSTRUCTIONS];
logic pc_rs_history [MAX_INSTRUCTIONS];
logic alu_pc_history [MAX_INSTRUCTIONS];
logic alu_im_history [MAX_INSTRUCTIONS];
logic alu_rs2_history [MAX_INSTRUCTIONS];
logic [3:0] alu_op_history [MAX_INSTRUCTIONS];
logic mem_rd_history [MAX_INSTRUCTIONS];
logic mem_wr_history [MAX_INSTRUCTIONS];
logic [3:0] mem_be_history [MAX_INSTRUCTIONS];
logic sign_ext_history [MAX_INSTRUCTIONS];
logic rf_wr_history [MAX_INSTRUCTIONS];
int inst_count = 0;
logic stop_collecting = 0;  // Flag to stop collecting after EBREAK

// Registers to store previous PC, instruction, and control signals (captured before clock edge)
logic [31:0] prev_pc;
logic [31:0] prev_instruction;
logic prev_reg_wr_en;
logic [4:0] prev_rd;
t_ctrl prev_ctrl;  // Store previous control signals

// assign clock and reset
initial begin
    // Setup VCD file for waveform dumping
    string vcd_path;
    if (!$value$plusargs("VCD=%s", vcd_path)) vcd_path = "target/core/core.vcd";
    $dumpfile(vcd_path);
    $dumpvars(0, core_tb);
    
    clk = 0;
    rst = 1;
    cycles = 0;
    #10 rst = 0;
end
// clock generation
always #5 clk = ~clk;

// Load instruction memory from compiled program
initial begin
    string mem_file;
    int fd, status;
    bit [7:0] memory[0:4095]; // Temporary memory for loading
    bit [31:0] address;
    
    // Initialize memory to zeros
    for (int i = 0; i < 128; i++) begin
        core.i_mem.mem[i] = 8'h00;
    end
    
    // Open memory file and read content
    mem_file = "verif/core/inst_mem.sv";
    $display("Loading instruction memory from %s...", mem_file);
    
    // Use system task to load memory from inst_mem.sv
    fd = $fopen(mem_file, "r");
    if (fd) begin
        $display("Successfully opened memory file");
        // The $readmemh function will automatically handle the @address directives
        $readmemh(mem_file, core.i_mem.mem);
        $fclose(fd);
    end else begin
        $display("Error: Could not open memory file %s", mem_file);
        $finish;
    end
    
    @(negedge rst);
    @(posedge clk);
end

// Capture PC, instruction, and control signals on negedge (they're stable and represent what will execute)
// On the next posedge, these will be the "previous" values (the ones that just executed)
always @(negedge clk) begin
    if (!rst) begin
        prev_pc = core.pc_out;
        prev_instruction = core.instruction;
        prev_reg_wr_en = core.ctrl.reg_wr_en;
        prev_rd = core.rf.rd;
        prev_ctrl = core.ctrl;  // Store all control signals
    end
end

//check if ebreak is hit and display summary table
always @(posedge clk) begin
    if (core.instruction == 32'h00100073) begin  // EBREAK
        stop_collecting = 1;  // Stop collecting new instructions
        $display("EBREAK hit at time %0t", $time);
        display_summary_table();
        $finish;
    end
end

// Cycle counter and simulation termination
always @(posedge clk) begin
    cycles <= cycles + 1;
    if (cycles >= MAX_CYCLES) begin
        $display("Simulation reached maximum cycle count of %0d", MAX_CYCLES);
        $finish;
    end
end

// Function to convert string to fixed array
function logic [7:0][7:0] str_to_array(input string s);
    logic [7:0][7:0] arr;
    for (int i = 0; i < 8; i++) begin
        arr[i] = (i < s.len()) ? s[i] : 8'h20;  // Pad with spaces
    end
    return arr;
endfunction

// Function to display control signals in a table format
function void display_ctrl_signals;
    string pc_sel_str;
    string alu_in1_str;
    string alu_in2_str;
    string alu_op_str;
    string mem_be_str;
    
    // Format each signal as 0/1
    if (core.ctrl.sel_next_pc_alu_out)
        pc_sel_str = "PC+im";
    else if (core.ctrl.sel_wb)
        pc_sel_str = "PC+rs";
    else
        pc_sel_str = "PC+4";
        
    alu_in1_str = core.ctrl.sel_alu_pc ? "PC" : "rs1";
    alu_in2_str = core.ctrl.sel_alu_imm ? "imm" : "rs2";
    alu_op_str = $sformatf("%4b", core.ctrl.alu_op);
    mem_be_str = $sformatf("%4b", core.ctrl.mem_byt_en);
    
    $display("\nControl Signals Table:");
    $display("┌─────────────────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐");
    $display("│ Instruction     │PC+4 │PC+im│PC+rs│ALUPC│ALUim│ALUr2│ALUop│MEMrd│MEMwr│MEMbe│SIGN │RFwrt│");
    $display("├─────────────────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤");
    
    $display("│ %-15s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │",
             get_instruction_name(core.instruction),
             (!core.ctrl.sel_next_pc_alu_out && !core.ctrl.sel_wb) ? "1" : "0",  // PC+4 is selected when neither sel_next_pc_alu_out nor sel_wb is set
             core.ctrl.sel_next_pc_alu_out ? "1" : "0",  // PC+im is selected when sel_next_pc_alu_out is set
             (!core.ctrl.sel_next_pc_alu_out && core.ctrl.sel_wb) ? "1" : "0",  // PC+rs is selected when sel_wb is set but sel_next_pc_alu_out is not
             (alu_in1_str == "PC") ? "1" : "0",
             (alu_in2_str == "imm") ? "1" : "0",
             (alu_in2_str == "rs2") ? "1" : "0",
             alu_op_str,
             core.ctrl.sel_dmem_wb ? "1" : "0",
             core.ctrl.mem_wr_en ? "1" : "0",
             mem_be_str,
             core.ctrl.sign_ext ? "1" : "0",
             core.ctrl.reg_wr_en ? "1" : "0");
    $display("└─────────────────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘");
endfunction

// Function to get instruction name
function string get_instruction_name(input logic [31:0] instruction);
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    opcode = instruction[6:0];
    funct3 = instruction[14:12];
    funct7 = instruction[31:25];
    
    case (opcode)
        7'b0110011: begin // R-type
            case ({funct7, funct3})
                10'b0000000000: return "ADD";
                10'b0100000000: return "SUB";
                10'b0000000001: return "SLL";
                10'b0000000010: return "SLT";
                10'b0000000011: return "SLTU";
                10'b0000000100: return "XOR";
                10'b0000000101: return "SRL";
                10'b0100000101: return "SRA";
                10'b0000000110: return "OR";
                10'b0000000111: return "AND";
                default: return "R-TYPE";
            endcase
        end
        7'b0010011: begin // I-type
            case (funct3)
                3'b000: return "ADDI";
                3'b001: return "SLLI";
                3'b010: return "SLTI";
                3'b011: return "SLTIU";
                3'b100: return "XORI";
                3'b101: return (instruction[30] ? "SRAI" : "SRLI");
                3'b110: return "ORI";
                3'b111: return "ANDI";
                default: return "I-TYPE";
            endcase
        end
        7'b0000011: begin // Load
            case (funct3)
                3'b000: return "LB";
                3'b001: return "LH";
                3'b010: return "LW";
                3'b100: return "LBU";
                3'b101: return "LHU";
                default: return "LOAD";
            endcase
        end
        7'b0100011: begin // Store
            case (funct3)
                3'b000: return "SB";
                3'b001: return "SH";
                3'b010: return "SW";
                default: return "STORE";
            endcase
        end
        7'b1100011: begin // Branch
            case (funct3)
                3'b000: return "BEQ";
                3'b001: return "BNE";
                3'b100: return "BLT";
                3'b101: return "BGE";
                3'b110: return "BLTU";
                3'b111: return "BGEU";
                default: return "BRANCH";
            endcase
        end
        7'b1101111: return "JAL";
        7'b1100111: return "JALR";
        7'b0110111: return "LUI";
        7'b0010111: return "AUIPC";
        7'b1110011: return (instruction[31:20] == 12'h001) ? "EBREAK" : "ECALL";
        default: return "UNKNOWN";
    endcase
endfunction

// Function to collect instruction info (uses previous values captured before clock edge)
function void collect_inst_info;
    if (inst_count < MAX_INSTRUCTIONS) begin
        // Use previous PC and instruction (the ones that just executed)
        pc_history[inst_count] = prev_pc;
        inst_history[inst_count] = prev_instruction;
        inst_names[inst_count] = get_instruction_name(prev_instruction);
        
        // Use stored previous control signals (from the instruction that just executed)
        pc_plus4_history[inst_count] = !prev_ctrl.sel_next_pc_alu_out;  // PC+4 is selected when sel_next_pc_alu_out is 0
        pc_im_history[inst_count] = prev_ctrl.sel_next_pc_alu_out;
        // Fix: PC+rs should only be 1 for branch/jump instructions, not based on sel_wb
        pc_rs_history[inst_count] = 1'b0;  // PC+rs is only for branches/jumps, which use sel_next_pc_alu_out
        alu_pc_history[inst_count] = prev_ctrl.sel_alu_pc;
        alu_im_history[inst_count] = prev_ctrl.sel_alu_imm;
        alu_rs2_history[inst_count] = !prev_ctrl.sel_alu_imm;
        alu_op_history[inst_count] = prev_ctrl.alu_op;
        mem_rd_history[inst_count] = prev_ctrl.sel_dmem_wb;
        mem_wr_history[inst_count] = prev_ctrl.mem_wr_en;
        mem_be_history[inst_count] = prev_ctrl.mem_byt_en;
        sign_ext_history[inst_count] = prev_ctrl.sign_ext;
        rf_wr_history[inst_count] = prev_reg_wr_en;  // Use previous reg_wr_en
        
        inst_count++;
    end
endfunction

// Function to display summary table
function void display_summary_table;
    $display("\n\nInstruction Execution Summary:");
    $display("┌──────────┬──────────┬──────────┬─────┬─────┬─────┬─────┬─────┬─────┬──────┬─────┬─────┬──────┬─────┬─────┐");
    $display("│ PC       │ Inst     │ Name     │PC+4 │PC+im│PC+rs│ALUPC│ALUim│ALUr2│ALUop │MEMrd│MEMwr│MEMbe │SIGN │RFwrt│");
    $display("├──────────┼──────────┼──────────┼─────┼─────┼─────┼─────┼─────┼─────┼──────┼─────┼─────┼──────┼─────┼─────┤");
    
    for (int i = 0; i < inst_count; i++) begin
        $display("│ %08h │ %08h │ %-8s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-3s │ %-4s │ %-3s │ %-3s │ %-4s │ %-3s │ %-3s │",
                 pc_history[i],
                 inst_history[i],
                 inst_names[i],
                 pc_plus4_history[i] ? "1" : "0",
                 pc_im_history[i] ? "1" : "0",
                 pc_rs_history[i] ? "1" : "0",
                 alu_pc_history[i] ? "1" : "0",
                 alu_im_history[i] ? "1" : "0",
                 alu_rs2_history[i] ? "1" : "0",
                 $sformatf("%04b", alu_op_history[i]),
                 mem_rd_history[i] ? "1" : "0",
                 mem_wr_history[i] ? "1" : "0",
                 $sformatf("%04b", mem_be_history[i]),
                 sign_ext_history[i] ? "1" : "0",
                 rf_wr_history[i] ? "1" : "0");
    end
    
    $display("└──────────┴──────────┴──────────┴─────┴─────┴─────┴─────┴─────┴─────┴──────┴─────┴─────┴──────┴─────┴─────┘");
endfunction

// Monitor for instruction fetch and register file changes
// Use negedge to capture values after they've settled from previous instruction
always @(negedge clk) begin
    if (!rst && !stop_collecting && (prev_instruction != 32'h00100073)) begin  // Don't collect EBREAK
        $write("Time %0t: PC=%08h, Instruction=%08h", 
               $time, 
               prev_pc,
               prev_instruction);
                
        // Only show register writes when rd is not x0
        if (prev_reg_wr_en && (prev_rd != 0)) begin
            $write(", Register x%0d = %08h", prev_rd, core.rf.write_d);
        end
        
        if(prev_instruction[6:0] == 7'b0000011) begin
            if((prev_ctrl.mem_byt_en == 4'b0001) && (prev_ctrl.sign_ext == 1'b1)) begin
                $write(", LB  mem[%08h]", core.alu_out);
            end else if(prev_ctrl.mem_byt_en == 4'b0011) begin
                $write(", LH  mem[%08h]", core.alu_out);
            end else if(prev_ctrl.mem_byt_en == 4'b1111) begin
                $write(", LW  mem[%08h]", core.alu_out);
            end
            else if((prev_ctrl.mem_byt_en == 4'b0001) && (prev_ctrl.sign_ext == 1'b0)) begin
                $write(", LBU mem[%08h]", core.alu_out);
            end else if(prev_ctrl.mem_byt_en == 4'b0011) begin
                $write(", LHU mem[%08h]", core.alu_out);
            end else if(prev_ctrl.mem_byt_en == 4'b1111) begin
                $write(", LW  mem[%08h]", core.alu_out);
            end
        end
        
        if(prev_ctrl.mem_wr_en) begin
            if(prev_ctrl.mem_byt_en == 4'b0001) begin
                $write(", SB  mem[%08h] = %h", core.alu_out, core.reg_data2[7:0]);
            end else if(prev_ctrl.mem_byt_en == 4'b0011) begin
                $write(", SH  mem[%08h] = %h", core.alu_out, core.reg_data2[15:0]);
            end else if(prev_ctrl.mem_byt_en == 4'b1111) begin
                $write(", SW  mem[%08h] = %08h", core.alu_out, core.reg_data2);
            end
        end
        
        $display("");
    end
end

// Collect instruction info on posedge (after values have been captured on negedge)
always @(posedge clk) begin
    if (!rst && !stop_collecting && (prev_instruction != 32'h00100073)) begin  // Don't collect EBREAK
        // Collect instruction info using previous values
        collect_inst_info();
    end
end

core core(
    .clk(clk),
    .rst(rst)
);

endmodule