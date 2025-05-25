// Simple test program for RISC-V CPU
// Uses only supported instructions: addi, add, nop

int main() {
    // Test 1: Basic arithmetic
    int x1 = 1;  // addi x1, x0, 1
    int x2 = 2;  // addi x2, x0, 2
    int x3 = x1 + x2;  // add x3, x1, x2

    // Test 2: More arithmetic
    int x4 = 5;  // addi x4, x0, 5
    int x5 = x3 + x4;  // add x5, x3, x4

    // Infinite loop (halt)
    while(1) {
        // nop
    }

    return 0;  // Never reached
}