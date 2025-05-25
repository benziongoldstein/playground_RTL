.section .text
.globl main

main:
    addi x1, x0, 1      # x1 = 1
    addi x2, x0, 2      # x2 = 2
    add  x3, x1, x2     # x3 = x1 + x2
    nop                 # Do nothing (safe infinite loop)
    nop
