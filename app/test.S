.section .text
.global main

main:
    # Initialize test values
    li x1, 5      # x1 = 5
    li x2, 5      # x2 = 5 (equal to x1)
    li x3, 6      # x3 = 6 (greater than x1)
    li x4, 4      # x4 = 4 (less than x1)
    li x5, -5     # x5 = -5 (negative)
    li x6, -6     # x6 = -6 (more negative)
    li x7, 0xFFFFFFFF  # x7 = -1 (unsigned: largest)
    li x8, 0x80000000  # x8 = -2^31 (signed: most negative)

    # Test 1: BEQ (Branch if Equal)
    # Should take branch (x1 == x2)
    beq x1, x2, beq_taken
    li x10, 1     # Should be skipped
    li x11, 2     # Should be skipped
beq_taken:
    li x12, 3     # Should execute

    # Test 2: BNE (Branch if Not Equal)
    # Should take branch (x1 != x3)
    bne x1, x3, bne_taken
    li x13, 1     # Should be skipped
    li x14, 2     # Should be skipped
bne_taken:
    li x15, 3     # Should execute

    # Test 3: BLT (Branch if Less Than, signed)
    # Should take branch (x4 < x1)
    blt x4, x1, blt_taken
    li x16, 1     # Should be skipped
    li x17, 2     # Should be skipped
blt_taken:
    li x18, 3     # Should execute
    nop
    nop
    ebreak
