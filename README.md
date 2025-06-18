# RTL Playground

<!-- GitHub Actions Workflow Status -->
![RTL_Build](https://github.com/benziongoldstein/playground_RTL/actions/workflows/build.yml/badge.svg?branch=master)

This repository is my personal RTL (Register Transfer Level) playground for experimenting with digital design using Verilog and SystemVerilog. Here, I will add various projects as I explore and learn more about hardware design.

## Projects 

### 1. RISC-V CPU Core
A complete 5-stage Single Cycle RISC-V CPU implementation featuring:
- **5-Stage Single Cycle**: IF (Instruction Fetch), ID (Instruction Decode), EX (Execute), MEM (Memory Access), WB (Write Back)
- **Core Components**: Program Counter, Decoder, Register File, ALU, Memory, Branch Condition Unit
- **RISC-V Support**: ALU operations (ADD, SUB, SLT, SLTU, SLL, SRL, SRA, XOR, OR, AND), Branch operations (BEQ, BNE, BLT, BGE, BLTU, BGEU), Load/Store with byte-enable and sign extension
- **Test Applications**: C and assembly programs in the `app/` directory with RISC-V toolchain support

#### Core Components:
- **Program Counter (PC)**: Parameterized program counter module supporting synchronous operations and configurable bit width
- **Register File (RF)**: Parameterized register file implementation with configurable width and depth, supporting synchronous write and asynchronous read operations
- **Arithmetic Logic Unit (ALU)**: Parameterized ALU implementation supporting various arithmetic and logical operations, with configurable data width
- **Decoder**: Instruction decode and control signal generation
- **Memory**: Unified instruction/data memory with byte-enable and sign extension
- **Branch Condition Unit**: Branch/jump condition evaluation

### 2. Traffic Light Controller
A parameterized traffic light controller implemented in SystemVerilog. This project demonstrates a simple finite state machine (FSM) for controlling traffic lights, including a testbench for simulation.

### 3. FIFO (First-In-First-Out) 8-bit
A parameterized 8-bit FIFO buffer implementation with:
- 8-location circular buffer with 1-bit data width
- Push/pop operations with full/empty status indicators
- Write and read pointer management
- Macro-based D flip-flop instantiation

### 4. LIFO (Last-In-First-Out) 8-bit
A parameterized 8-bit LIFO stack implementation with:
- 8-location stack with 1-bit data width
- Push/pop operations with full/empty status indicators
- Stack pointer management for LIFO behavior
- Macro-based D flip-flop instantiation

### 5. Common Components
A collection of reusable digital design components including:
- D Flip-Flop with synchronous reset
- Parameterized multiplexers
- Other common digital building blocks

#### Installation Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/benziongoldstein/playground_RTL.git
   cd playground_RTL
   ```
2. **Install dependencies:**
   - [Icarus Verilog](http://iverilog.icarus.com/) (for simulation)
   - [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)
   - RISC-V GCC toolchain (for compiling C programs in the `app/` directory)

3. **Build and simulate using the builder script (recommended):**
   ```bash
   python3 build/builder.py <project_name> -all
   ```
   Replace `<project_name>` with any of the project names (e.g., `core`, `traffic_light`, `pc`, `rf`, `alu`).
   - This will compile, simulate, and open GTKWave for the selected project.
   - You can also use `-hw` (compile only), `-sim` (simulate), or `-gui` (view waveforms) as needed.

4. **Manual compile (if you prefer):**
   ```bash
   iverilog -g2012 -I source/common -f verif/<project_name>/<project_name>_list.f
   vvp a.out
   gtkwave <project_name>.vcd
   ```
   - Each project has its own file list in `verif/<project_name>/<project_name>_list.f` containing the required source and testbench files.

5. **Compile RISC-V applications:**
   ```bash
   cd app/
   make
   ```

#### Project-Specific Features

##### RISC-V CPU Core
- Complete 5-stage pipeline implementation
- Unified instruction and data memory
- Branch condition evaluation unit
- Support for RISC-V instruction set operations
- Test applications with C and assembly code
- Comprehensive core testbench with instruction memory

**Core Components Features:**
- **Program Counter (PC)**: Parameterized bit width, synchronous operations, optional enable and reset functionality
- **Register File (RF)**: Configurable data width and number of registers, synchronous write with write enable, asynchronous read, dual-port read capability
- **ALU**: Parameterized data width, multiple arithmetic operations (ADD, SUB, etc.), logical operations (AND, OR, XOR, etc.), status flags (Zero, Carry, Overflow)
- **All components**: Individual testbenches with various test scenarios

##### Traffic Light Controller
- Parameterized state durations for RED, RED+YELLOW, GREEN, and YELLOW
- Synchronous reset
- Macro-based D flip-flop instantiation
- Comprehensive testbench for simulation

##### FIFO 8-bit
- 8-location circular buffer with 1-bit data elements
- Push/pop operations with enable controls
- Full and empty status indicators
- Write and read pointer management
- Uses DFF macros for sequential logic

##### LIFO 8-bit
- 8-location stack with 1-bit data elements
- Push/pop operations following LIFO behavior
- Stack pointer for top-of-stack tracking
- Full and empty status indicators
- Uses DFF macros for sequential logic

#### Contributing

Contributions are welcome! Please fork the repository and submit a pull request. For major changes, open an issue first to discuss what you would like to change.

#### License

This project is open source and free to use for any purpose. Feel free to modify, distribute, and use it as you wish.

#### Contact Information

For questions or support, please contact the maintainer at benziong@mail.tau.ac.il.

---

*More projects will be added as this playground grows!*