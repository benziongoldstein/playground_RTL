.section .text.init
.global _start

_start:
    # Just NOPs and jump to main
    nop
    nop
    call main
    j . 