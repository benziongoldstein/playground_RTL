.section .text
.globl main

main:
    nop
   # Test case 1: Basic OR (either bit 1)
    addi x1, x0, 5      # x1 = 5 (binary: 0101)
    addi x2, x0, 3      # x2 = 3 (binary: 0011)
    or   x3, x1, x2     # x3 = x1 | x2 = 7 (binary: 0111)
    
    # Test case 2: OR with same number
    addi x4, x0, 7      # x4 = 7 (binary: 0111)
    addi x5, x0, 7      # x5 = 7 (binary: 0111)
    or   x6, x4, x5     # x6 = x4 | x5 = 7 (binary: 0111)
    nop
