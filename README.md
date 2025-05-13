# RTL Playground

This repository is my personal RTL (Register Transfer Level) playground for experimenting with digital design using Verilog and SystemVerilog. Here, I will add various projects as I explore and learn more about hardware design.


### 1. Traffic Light Controller
A parameterized traffic light controller implemented in SystemVerilog. This project demonstrates a simple finite state machine (FSM) for controlling traffic lights, including a testbench for simulation.

### 2. Program Counter (PC)
A parameterized program counter module for CPU design, supporting synchronous operations and configurable bit width.

### 3. Register File (RF)
A parameterized register file implementation with configurable width and depth, supporting synchronous write and asynchronous read operations.

### 4. Arithmetic Logic Unit (ALU)
A parameterized ALU implementation supporting various arithmetic and logical operations, with configurable data width.

### 5. Common Components
A collection of reusable digital design components including:
- D Flip-Flop with synchronous reset
- Parameterized multiplexers
- Other common digital building blocks

#### Installation Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/benziongoldstein/verilog_projects.git
   cd verilog_projects
   ```
2. **Install dependencies:**
   - [Icarus Verilog](http://iverilog.icarus.com/) (for simulation)
   - [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)

3. **Build and simulate using the builder script (recommended):**
   ```bash
   python3 build/builder.py <project_name> -all
   ```
   Replace `<project_name>` with any of the project names (e.g., `traffic_light`, `pc`, `rf`, `alu`).
   - This will compile, simulate, and open GTKWave for the selected project.
   - You can also use `-hw` (compile only), `-sim` (simulate), or `-gui` (view waveforms) as needed.

4. **Manual compile (if you prefer):**
   ```bash
   iverilog -g2012 -I source/common -f verif/<project_name>/<project_name>_list.f
   vvp a.out
   gtkwave <project_name>.vcd
   ```
   - Each project has its own file list in `verif/<project_name>/<project_name>_list.f` containing the required source and testbench files.

#### Project-Specific Features

##### Traffic Light Controller
- Parameterized state durations for RED, RED+YELLOW, GREEN, and YELLOW
- Synchronous reset
- Macro-based D flip-flop instantiation
- Comprehensive testbench for simulation

##### Program Counter (PC)
- Parameterized bit width
- Synchronous operations
- Optional enable and reset functionality
- Testbench with various test scenarios

##### Register File (RF)
- Configurable data width and number of registers
- Synchronous write with write enable
- Asynchronous read
- Dual-port read capability
- Testbench with read/write verification

##### ALU
- Parameterized data width
- Multiple arithmetic operations (ADD, SUB, etc.)
- Logical operations (AND, OR, XOR, etc.)
- Status flags (Zero, Carry, Overflow)
- Comprehensive testbench

#### Contributing

Contributions are welcome! Please fork the repository and submit a pull request. For major changes, open an issue first to discuss what you would like to change.

#### License

This project is open source and free to use for any purpose. Feel free to modify, distribute, and use it as you wish.

#### Contact Information

For questions or support, please contact the maintainer at benziong@mail.tau.ac.il.

---

*More projects will be added as this playground grows!* 