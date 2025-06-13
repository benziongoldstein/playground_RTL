/*
 * Minimal RISC-V test program with only additions
 */
int add(int a, int b) {
    return a + b;
}

int main() {
    // Use only addition operations
    volatile int a = 1;
    volatile int b = 2;
    volatile int d = 3;
    volatile int e = 4;
    volatile int f = 5;
    volatile int g = 6;
    volatile int h = 7;
    volatile int i = 8;
    volatile int j = 9;
    volatile int k = 10;
    volatile int l = 11;
    volatile int m = 12;
    volatile int c = add(a, b);
    return c;  // Return the sum
}