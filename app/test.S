.section .text
.globl main

main:
    nop

    # Test 1: Byte loads with -1
    addi x3, x0, 0x100      # x3 = 0x100 (base address)
    addi x2, x0, -1         # x2 = -1 (0xFFFFFFFF)
    sb x2, 0(x3)            # mem[0x100] = 0xFF
    lb x1, 0(x3)            # x1 should be 0xFFFFFFFF (signed)
    lbu x4, 0(x3)           # x4 should be 0x000000FF (unsigned)
    nop

    # Test 2: Half-word loads with -1
    addi x3, x0, 0x104      # x3 = 0x104 (new base address)
    addi x2, x0, -1         # x2 = -1 (0xFFFFFFFF)
    sh x2, 0(x3)            # mem[0x104] = 0xFFFF
    lh x1, 0(x3)            # x1 should be 0xFFFFFFFF (signed)
    lhu x4, 0(x3)           # x4 should be 0x0000FFFF (unsigned)
    nop

    # Test 3: Byte loads with 0x80 (negative in signed, positive in unsigned)
    addi x3, x0, 0x108      # x3 = 0x108 (new base address)
    addi x2, x0, 0x80       # x2 = 0x80 (128 decimal)
    sb x2, 0(x3)            # mem[0x108] = 0x80
    lb x1, 0(x3)            # x1 should be 0xFFFFFF80 (signed)
    lbu x4, 0(x3)           # x4 should be 0x00000080 (unsigned)
    nop

    # Test 4: Word loads with large value (0xFFFF)
    addi x3, x0, 0x104      # x3 = 0x104 (new base address)
    lui x2, 0x1             # x2 = 0x1000
    addi x2, x2, -1         # x2 = 0x0FFF
    addi x2, x2, 1          # x2 = 0x1000
    addi x2, x2, -1         # x2 = 0x0FFF
    lui x5, 0x1             # x5 = 0x1000
    sub x2, x2, x5          # x2 = 0xFFFF
    sh x2, 0(x3)            # mem[0x104] = 0xFFFF
    lh x1, 0(x3)            # x1 should be 0xFFFFFFFF (signed)
    lhu x4, 0(x3)           # x4 should be 0x0000FFFF (unsigned)
    nop
    nop
    ebreak
