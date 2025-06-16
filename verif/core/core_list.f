# File list for PC simulation
# Include directories
+incdir+source/common
+incdir+source/pc

# Source files
source/common/cpu_pkg.sv
source/core/core.sv
source/decoder/decoder.sv
source/mem/mem.sv
source/pc/pc.sv
source/rf/rf.sv
source/alu/alu.sv
source/branch_cond/branch_cond.sv

//testbench
verif/core/core_tb.sv
