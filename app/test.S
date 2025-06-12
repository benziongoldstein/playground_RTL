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

    # Test 4: BGE (Branch if Greater or Equal, signed)
    # Should NOT take branch (x3 > x1)
    bge x1, x3, bge_taken
    li x19, 1     # Should execute
    li x20, 2     # Should execute
bge_taken:
    li x21, 3     # Should be skipped

    # Test 5: BLTU (Branch if Less Than, unsigned)
    # Should take branch (x1 < x7)
    bltu x1, x7, bltu_taken
    li x22, 1     # Should be skipped
    li x23, 2     # Should be skipped
bltu_taken:
    li x24, 3     # Should execute

    # Test 6: BGEU (Branch if Greater or Equal, unsigned)
    # Should NOT take branch (x7 > x1)
    bgeu x1, x7, bgeu_taken
    li x25, 1     # Should execute
    li x26, 2     # Should execute
bgeu_taken:
    li x27, 3     # Should be skipped

    # Test 7: Signed vs Unsigned comparison
    # Should take branch (x5 > x6 signed, but x5 < x6 unsigned)
    blt x5, x6, signed_taken
    li x28, 1     # Should be skipped
    li x29, 2     # Should be skipped
signed_taken:
    li x30, 3     # Should execute

    # Test 8: Edge cases
    # Should take branch (x8 is most negative signed number)
    blt x8, x5, edge_taken
    li x31, 1     # Should be skipped
edge_taken:
    li t0, 2      # Should execute

    # Program end
    nop
    nop
    ebreak
