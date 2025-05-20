/* Minimal RISC-V linker script */
OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
  .text : {
    *(.text.init)
    *(.text)
  } > RAM

  .rodata : {
    *(.rodata)
  } > RAM

  .data : {
    *(.data)
  } > RAM

  .bss : {
    *(.bss)
    *(COMMON)
  } > RAM

  /* Stack grows down from the end of RAM */
  PROVIDE(_stack_top = ORIGIN(RAM) + LENGTH(RAM));
} 