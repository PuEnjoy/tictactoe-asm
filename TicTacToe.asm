;data section
section .data
    grid db ".",9,".",9,".",10,".",9,".",9,".",10,".",9,".",9,".",10    ;build simple grid with tab (9) and linebreak (10) seperations
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

    
;block starting symbol - uninitialised data section. Initialized to 0 on startup. Modified during runtime
section .bss
    inputBuffer resb 256            ;initialize buffer to 256 byte even tho only 1 is used (prevent accidental command execution)

;main code section
section .text
global _start                       ;declare _start as global

_start:
    mov r12, "X"                    ;use non-volatile register r12 to store whos turn it is.
    call _printIntro                ;
    mov rax, 1                      ;Setup syscall to ask for user input (only print)
    mov rdi, 1                      ;
    lea rsi, [askInputMsgX]         ;
    mov rdx, askInputMsgXLen        ;
    syscall                         ;syscall
    call _get_input                 ;function call to handle user input
    call _print_grid                ;
    call _get_input                 ;
    call _print_grid                ;
    call _get_input                 ;
    call _print_grid                ;
    jmp _exit                       ;jump to program no error exit function

_get_input:
    mov rax, 0                      ;syscall setup to take user input (stdin)
    mov rdi, 1                      ;
    lea rsi, [inputBuffer]          ;
    mov rdx, 256                    ;large inputBuffer to prevent accidental overflows which can lead to command execution
    syscall                         ;syscall
    mov rax, 1                      ;aesthetic print syscall
    mov rdi, 1                      ;
    lea rsi, [placeholer]           ;
    mov rdx, placeholerLen          ;
    syscall                         ;exection of syscall
    call _placeSymbol               ;
    test rax, rax                   ;test rax on rax -> return code 0 (No Error), 1 (Error)
    jz .changeSymbol                ;call .changeSymbol if no error occured
    jmp _get_input                  ;start _get_input loop again in case of error

    .changeSymbol:                  ;subFunction
        test r12, 1                 ;test r12 odd or even
        je .changeToO               ;even test mean current symbol is X (ascii 88) -> change to O
        jmp .changeToX              ;odd test implies current symbol is O (ascii 79) -> change to X
    .changeToX:                     ;
        add r12, 9                  ;change symbol by adding 9 on ascii code
        ret                         ;
    .changeToO:                     ;
        sub r12, 9                  ;change symbol by subtracting 9 from ascii code
        ret                         ;


_placeSymbol:
    ;Here we convert the user input into the corresponding position of our game grid
    xor rax, rax                    ;zero rax
    mov al, byte [inputBuffer]      ;move first byte from input buffer into lower 8bit of rax
    sub al, '0'                     ;convert ascii to integer    
    mov rsi, 2                      ;
    mul rsi                         ;mul input by 2
    sub rax, 2                      ;sub result by 2
    ;At this point the lower 8bit of rax contain the selected location of the grid as we can use it to navigate the grid data  
    xor rdi, rdi                    ;
    mov rdi, "."                    ;
    mov dl, byte [grid+rax]         ;get the symbol at the selected location
    cmp dl, dil                     ;compare selected symbol to "." / 46
    jne .placeTakenError            ;jmp if selected symbol is not free "."
    mov byte [grid+rax], r12b       ;place active symbol at grid location
    xor rax, rax                    ;
    ret                             ;no error return

    .placeTakenError:               ;
        mov rax, 1                  ;syscall setup to print place taken error message
        mov rdi, 1                  ;
        lea rsi, [placeTaken]       ;
        mov rdx, placeTakenLen      ;
        syscall                     ;
        mov rax, 1                  ;indicate error
        jmp _get_input              ;return to get input loop


_printIntro:
    mov rax, 1                      ;syscall setup to print welcome message
    mov rdi, 1                      ;
    lea rsi, [welcomeMsg]           ;
    mov rdx, welcomeMsgLen          ;
    syscall                         ;
    mov rax, 1                      ;syscall setup to print placeholder
    mov rdi, 1                      ;
    lea rsi, [placeholer]           ;
    mov rdx, placeholerLen          ;
    syscall                         ;
    mov rax, 1                      ;syscall setup to print grid intro
    mov rdi, 1                      ;
    lea rsi, [gridIntro]            ;
    mov rdx, gridIntroLen           ;
    syscall                         ;
    mov rax, 1                      ;syscall setup to print placeholder
    mov rdi, 1                      ;
    lea rsi, [placeholer]           ;
    mov rdx, placeholerLen          ;
    syscall                         ;
    ret                             ;return 


;function handling simple syscall setup for stdout (used for printing the grid)
_print_grid:
    mov rax, 1                      ;syscall setup to print the grid
    mov rdi, 1                      ;formatting happens in datasection
    lea rsi, [grid]                 ;
    mov rdx, gridlen                ;
    syscall                         ;
    mov rax, 1                      ;syscall setup to print placeholder
    mov rdi, 1                      ;
    lea rsi, [placeholer]           ;
    mov rdx, placeholerLen          ;
    syscall                         ;
    ret                             ;

;syscall setup to exit the program voluntarily without error 
_exit:
    mov rax, 60                     ;sys_exit code
    mov rdi, 0                      ;no error
    syscall                         ;execute syscall