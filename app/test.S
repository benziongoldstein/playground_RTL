.section .text
.global _start

_start:
    # Your test instructions here
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    nop                 # No operation
    addi x10, x0, 1     # Load immediate 1 into x10
    addi x11, x0, 2     # Load immediate 2 into x11
    add x12, x11, x10   # Add x10 and x11, store in x12
    sub x13, x12, x10   # Subtract x10 from x12, store in x13x10, x