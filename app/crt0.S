.section .text.init
.globl _start

_start:
    la sp, _stack_top   # Set up stack pointer to the top of RAM
    nop                 # Optional: NOP for alignment or debug
    nop                 # Optional: NOP for alignment or debug
    call main           # Call main (if you have a main function)
    nop 
    ebreak              
    j .                 # Infinite loop after main returns

.section .bss
.space 1024             # Reserve 1KB for stack (optional, for small programs)
.globl _stack_top
_stack_top:
