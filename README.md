# RTL Playground

This repository is my personal RTL (Register Transfer Level) playground for experimenting with digital design using Verilog and SystemVerilog. Here, I will add various projects as I explore and learn more about hardware design.

## Projects

### 1. Traffic Light Controller
A parameterized traffic light controller implemented in SystemVerilog. This project demonstrates a simple finite state machine (FSM) for controlling traffic lights, including a testbench for simulation.

#### Installation Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/username/playground_RTL.git
   cd playground_RTL
   ```
2. **Install dependencies:**
   - [Icarus Verilog](http://iverilog.icarus.com/) (for simulation)
   - [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)

3. **Build and simulate using the builder script (recommended):**
   ```bash
   cd build
   python3 builder.py traffic_light -all
   ```
   - This will compile, simulate, and open GTKWave for the traffic light project.
   - You can also use `-hw` (compile only), `-sim` (simulate), or `-gui` (view waveforms) as needed.

4. **Manual compile (if you prefer):**
   ```bash
   iverilog -g2012 -I source/common -f verif/traffic_light/traffic_light_list.f
   vvp a.out
   gtkwave traffic.vcd
   ```
   - The file list `verif/traffic_light/traffic_light_list.f` contains the required source and testbench files.

#### Usage Guidelines

- Modify the timing parameters in the testbench or module instantiation to simulate different traffic light durations.
- Use the provided testbench (`verif/traffic_light/tb_traffic_light.sv`) to verify the design.
- View the output signals (`red`, `yellow`, `green`) in GTKWave for analysis.

#### Features

- Parameterized state durations for RED, RED+YELLOW, GREEN, and YELLOW.
- Synchronous reset.
- Macro-based D flip-flop instantiation for clean code.
- Comprehensive testbench for simulation.

#### Contributing

Contributions are welcome! Please fork the repository and submit a pull request. For major changes, open an issue first to discuss what you would like to change.

#### License

This project is open source and free to use for any purpose. Feel free to modify, distribute, and use it as you wish.

#### Contact Information

For questions or support, please contact the maintainer at benziong@mail.tau.ac.il.

---

*More projects will be added as this playground grows!* 