;data section
section .data
    grid db ".",9,".",9,".",10,".",9,".",9,".",10,".",9,".",9,".",10
    gridlen: equ $ - grid   ;grid length: equate difference from grid to current position
    
;read only data section
section .rodata


;main code section
section .text
global _start ;declare _start as global

;syscall setup for a simple stdout
_start:
    call _print_grid
    jmp _exit

;function handling simple syscall setup for stdout (used for printing the grid)
_print_grid:
    mov rax, 1
    mov rdi, 1
    lea rsi, [grid]
    mov rdx, gridlen
    syscall

;syscall setup to exit the program voluntarily without error 
_exit:
    mov rax, 60
    mov rdi, 0
    syscall

