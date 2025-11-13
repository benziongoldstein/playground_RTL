.section .text
.global main

main:
    # פעולות בסיסיות
    li x1, 10     # x1 = 10
    li x2, 5      # x2 = 5
    add x3, x1, x2   # x3 = x1 + x2 = 15
    sub x4, x1, x2   # x4 = x1 - x2 = 5
    and x5, x1, x2   # x5 = x1 & x2 = 0
    or x6, x1, x2    # x6 = x1 | x2 = 15
    xor x7, x1, x2   # x7 = x1 ^ x2 = 15
    beq x1, x2, branch_target  # Branch if x1 != x2 (should branch: 10 != 5)
    or x8, x1, x2   # x8 = x1 | x2 = 15 (skipped if branch taken)
branch_target:
    addi x8, x1, 20  # x8 = x1 + 20 = 30
    slli x9, x2, 2   # x9 = x2 << 2 = 20
    slt x10, x2, x1  # x10 = (x2 < x1) ? 1 : 0 = 1
    nop
    nop
    ebreak
