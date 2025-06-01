.section .text
.globl main

main:
    nop
    addi x1, x0, 6      # x1 = 6
    addi x2, x0, 5      # x2 = 5
    sub  x3, x1, x2     # x3 = x1 - x2 = 1
    nop                 # Do nothing (safe infinite loop)
