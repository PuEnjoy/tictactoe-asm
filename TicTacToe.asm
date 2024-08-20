;data section
section .data
    grid db ".",9,".",9,".",10,".",9,".",9,".",10,".",9,".",9,".",10
    gridlen: equ $ - grid   ;grid length: equate difference from grid to current position
    
;read only data section
section .rodata
    welcomeMsg: db "-- Welcome to TicTacToe in Assembly Language --", 10, "The playground uses the following layout:", 10, 10
    welcomeMsgLen: equ $ - welcomeMsg
    placeholer db "-------------------------------------------------", 10
    placeholerLen: equ $ - placeholer
    askInputMsgX db "Input a number from 1 to 9 to place an X", 10
    askInputMsgXLen: equ $ - askInputMsgX
    askInputMsgO db "Input a number from 1 to 9 to place an O", 10
    askInputMsgOLen: equ $ - askInputMsgO
    gridIntro db "X",9,".",9,".",9,"|",9,"1",9,"2",9,"3",10,".",9,".",9,"O",9,"|",9,"4",9,"5",9,"6",10,".",9,".",9,".",9,"|",9,"7",9,"8",9,"9",10
    gridIntroLen: equ $ - gridIntro
    placeTaken db "this location is already taken. Please choose again", 10
    placeTakenLen: equ $ - placeTaken

    

section .bss
    inputBuffer resb 256

;main code section
section .text
global _start ;declare _start as global

;syscall setup for a simple stdout
_start:
    mov r12, "X"
    call _printIntro
    ;print ask for input
    mov rax, 1
    mov rdi, 1
    lea rsi, [askInputMsgX]
    mov rdx, askInputMsgXLen
    syscall
    call _get_input
    call _print_grid
    call _get_input
    call _print_grid
    call _get_input
    call _print_grid
    jmp _exit

_get_input:
    mov rax, 0
    mov rdi, 1
    lea rsi, [inputBuffer]
    mov rdx, 256
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [placeholer]
    mov rdx, placeholerLen
    syscall
    call _placeSymbol
    test rax, rax
    jz .changeSymbol
    jmp _get_input
    ;this get executed even when teh place was taken! Needs fix
    .changeSymbol:
        test r12, 1
        je .changeToO
        jmp .changeToX
    .changeToX:
        add r12, 9
        ret
    .changeToO:
        sub r12, 9
        ret


_placeSymbol:
    ;check if the position is already taken
    xor rax, rax
    mov al, byte [inputBuffer]
    sub al, '0' ;convert ascii to number    
    ;multiply input value by 2
    mov rsi, 2
    mul rsi
    ;subtrackt 2
    sub rax, 2
    ;at this point we have the grid adress correlating to the input saved in rax (not handling wrong inputs yet!!!) 
    xor rdi, rdi
    mov rdi, "."
    mov dl, byte [grid+rax]
    cmp dl, dil
    jne .placeTakenError
    ;place Symbol at location:
    mov byte [grid+rax], r12b
    xor rax, rax
    ret

    .placeTakenError:
        mov rax, 1
        mov rdi, 1
        lea rsi, [placeTaken]
        mov rdx, placeTakenLen
        syscall
        mov rax, 1 ;indicate error
        jmp _get_input


_printIntro:
    ;print welcome message
    mov rax, 1
    mov rdi, 1
    lea rsi, [welcomeMsg]
    mov rdx, welcomeMsgLen
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [placeholer]
    mov rdx, placeholerLen
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [gridIntro]
    mov rdx, gridIntroLen
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [placeholer]
    mov rdx, placeholerLen
    syscall
    ret


_print_msg:
    mov rax, 1
    mov rdi, 1
    ;set rsi and rdx before function call
    syscall
    ret

;function handling simple syscall setup for stdout (used for printing the grid)
_print_grid:
    mov rax, 1
    mov rdi, 1
    lea rsi, [grid]
    mov rdx, gridlen
    syscall
    mov rax, 1
    mov rdi, 1
    lea rsi, [placeholer]
    mov rdx, placeholerLen
    syscall
    ret

;syscall setup to exit the program voluntarily without error 
_exit:
    mov rax, 60
    mov rdi, 0
    syscall