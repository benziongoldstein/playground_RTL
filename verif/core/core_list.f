# File list for core simulation
# Include directories
+incdir+source/common
+incdir+source/core
+incdir+source/decoder
+incdir+source/mem
+incdir+source/pc
+incdir+source/rf
+incdir+source/alu

# Package files
source/common/cpu_pkg.sv

# Source files
source/core/core.sv
source/decoder/decoder.sv
source/mem/mem.sv
source/pc/pc.sv
source/rf/rf.sv
source/alu/alu.sv

# Testbench
verif/core/core_tb.sv
