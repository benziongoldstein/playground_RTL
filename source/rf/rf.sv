`include "dff_macros.svh"  // Include D flip-flop macros for synchronous operations

// Register File Module
// This module implements a 32x32 register file for the RISC-V CPU
// Features:
// - 32 registers (x0-x31), each 32 bits wide
// - Dual read ports (can read two registers simultaneously)
// - Single write port (one write per cycle)
// - Special handling for x0 (always reads as 0, writes ignored)
module rf(
    input logic         clk,        // Clock for synchronous write operations
    input logic [4:0]   rs1,        // Read address 1 (selects first register to read)
    input logic [4:0]   rs2,        // Read address 2 (selects second register to read)
    input logic [4:0]   rd,         // Write address (selects register to write to)
    input logic         write_e,    // Write enable (1=write, 0=no write)
    input logic [31:0]  write_d,    // Data to write into register

    output logic [31:0] reg_data1,  // Data read from first register (rs1)
    output logic [31:0] reg_data2   // Data read from second register (rs2)
);

    logic [31:0] reg_file [31:0];   // 32 registers, each 32 bits (x0-x31)

    `DFF_EN(reg_file[rd], write_d, clk, write_e)  // Write to register on clock edge if write_e=1

    // Read operations: return 0 for x0, actual value for other registers
    assign reg_data1 = (rs1 == 5'b0) ? 32'b0 : reg_file[rs1];  // Read port 1
    assign reg_data2 = (rs2 == 5'b0) ? 32'b0 : reg_file[rs2];  // Read port 2

endmodule
