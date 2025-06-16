/* Minimal RISC-V linker script */
OUTPUT_ARCH("riscv")         /* Specify the target architecture */
ENTRY(_start)                 /* Set the entry point to _start */

MEMORY {
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 4K /* Define a 4KB RAM starting at address 0 */
}

SECTIONS {
  .text : {
    *(.text.init)             /* Initialization code (if any) */
    *(.text)                  /* All code sections */
  } > RAM

  .rodata : {
    *(.rodata)                /* Read-only data */
  } > RAM

  .data : {
    *(.data)                  /* Initialized data */
  } > RAM

  .bss : {
    *(.bss)                   /* Uninitialized data */
    *(COMMON)                 /* Common symbols (uninitialized globals) */
  } > RAM

  /* Stack grows down from the end of RAM */
  PROVIDE(_stack_top = ORIGIN(RAM) + LENGTH(RAM));
} 