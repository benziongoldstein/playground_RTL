/*
 * Minimal RISC-V test program with only additions
 */

int main() {
    // Use only addition operations
    volatile int a = 1;
    volatile int b = 2;
    volatile int c = a + b;    // c = 3
    volatile int d = a + c;    // d = 4
    volatile int e = b + d;    // e = 6
    
    // Simple infinite loop with addition
    while(1) {
        c = a + b;
    }
    
    return 0;
} 