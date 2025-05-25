/*
 * Minimal RISC-V test program with only additions
 */

int main() {
    // Use only addition operations
    volatile int a = 1;
    volatile int b = 2;
    volatile int c = a + b;

    while(1) {
        c = a + b;
    }

    return 0;
}