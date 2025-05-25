.section .text
.globl main

main:
    nop
    nop
    addi x1, x0, 5     # x1 = 5
    addi x2, x0, 6      # x2 = 6
    add  x3, x1, x2     # x3 = x1 + x2
    nop                 # Do nothing (safe infinite loop)
    nop
