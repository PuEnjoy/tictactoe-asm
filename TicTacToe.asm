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
    msgXwins: db "-- Congratulations X has won the Game --",10
    msgXwinsLen: equ $ - msgXwins
    msgOwins: db "-- Congratulations O has won the Game --",10
    msgOwinsLen: equ $ - msgOwins
    msgEndTie: db "-- The Game ended in a Tie --",10
    msgEndTieLen: equ $ - msgEndTie

    
;block starting symbol - uninitialised data section. Initialized to 0 on startup. Modified during runtime
section .bss
    inputBuffer resb 256            ;initialize buffer to 256 byte even tho only 1 is used (prevent accidental command execution)
    roundcounter resq 1

;main code section
section .text
global _start                       ;declare _start as global

_start:
    mov r12, "X"                    ;
    call _printIntro                ;
    mov rax, 1                      ;Setup syscall to ask for user input (only print)
    mov rdi, 1                      ;
    lea rsi, [askInputMsgX]         ;
    mov rdx, askInputMsgXLen        ;
    syscall                         ;syscall
    call _get_input                 ;function call to handle user input
    call _print_grid                ;
    ;Start of the Game Loop
    .nextTurn:
        test r12, 1                         ;test r12 odd or even
        je .promtX                          ;it is user Xs turn
        jmp .promtO                         ;it is user Ys turn
        .promtX:
            mov rax, 1                      ;Setup syscall to ask for user input (only print)
            mov rdi, 1                      ;
            lea rsi, [askInputMsgX]         ;
            mov rdx, askInputMsgXLen        ;
            syscall                         ;
            call _get_input                 ;
            call _print_grid                ;
            jmp .checkWin                   ;continue gameloop
        .promtO:
            mov rax, 1                      ;Setup syscall to ask for user input (only print)
            mov rdi, 1                      ;
            lea rsi, [askInputMsgO]         ;
            mov rdx, askInputMsgOLen        ;
            syscall                         ;
            call _get_input                 ;
            call _print_grid                ;
            jmp .checkWin                   ;continue gameloop
    .checkWin:
    mov rax, qword [roundcounter]           ;load roundcounter
    cmp rax, 5                              ;game finish possible after 5 turns
    jl .nextTurn
    call _winLogic                          ;current win logic can be more efficient by only checking affected rows after each placement 
    mov rax, qword [roundcounter]
    cmp rax, 9
    jl .nextTurn
    je _endTie

_winLogic:
    .firstRow:
    xor rax, rax                    ;zero rax
    movzx rax, byte [grid]          ;load first position in rax
    movzx rcx, byte [grid+2]        ;load second position in rcx
    add rax, rcx                    ;add
    movzx rcx, byte [grid+4]        ;load third position
    add rax, rcx                    ;add -> sum of all 3 locations
    call .winCheck                  ;check if the value correlates to a win
    .secondRow:
    xor rax, rax                    ;
    movzx rax, byte [grid+6]        ;
    movzx rcx, byte [grid+8]        ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+10]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    .thirdRow:
    xor rax, rax                    ;
    movzx rax, byte [grid+12]       ;
    movzx rcx, byte [grid+14]       ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+16]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    .firstColumn:
    xor rax, rax                    ;
    movzx rax, byte [grid]          ;
    movzx rcx, byte [grid+6]        ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+12]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    .secondColumn:
    xor rax, rax                    ;
    movzx rax, byte [grid+2]        ;
    movzx rcx, byte [grid+8]        ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+14]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    .thirdColumn:
    xor rax, rax                    ;
    movzx rax, byte [grid+4]        ;
    movzx rcx, byte [grid+10]       ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+16]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    .crossLeft:
    xor rax, rax                    ;
    movzx rax, byte [grid]          ;
    movzx rcx, byte [grid+8]        ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+16]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    .crossRight:
    xor rax, rax                    ;
    movzx rax, byte [grid+4]        ;
    movzx rcx, byte [grid+8]        ;
    add rax, rcx                    ;
    movzx rcx, byte [grid+12]       ;
    add rax, rcx                    ;
    call .winCheck                  ;
    xor rax, rax                    ;set return value to 0
    ret                             ;return without win

    .winCheck:
    cmp rax, 264                    ;check win X
    je .winX                        ;
    cmp rax, 237                    ;check win O
    je .winO                        ;
    ret                             ;return no win

    .winX:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msgXwins]
    mov rdx, msgXwinsLen
    syscall
    jmp _exit
    .winO:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msgOwins]
    mov rdx, msgOwinsLen
    syscall
    jmp _exit

_endTie:
    mov rax, 1
    mov rdi, 1
    lea rsi, [msgEndTie]
    mov rdx, msgEndTieLen
    syscall
    jmp _exit

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

.changeSymbol:                      ;subFunction
    mov rdi, qword [rel roundcounter]
    inc rdi                         ;increase rdi
    mov [rel roundcounter], rdi     ;store round back to counter
    test r12, 1                     ;test r12 odd or even
    je .changeToO                   ;even test means current symbol is X (ascii 88) -> change to O
    jmp .changeToX                  ;odd test implies current symbol is O (ascii 79) -> change to X
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
    mov rax, 1                      ;syscall setup to print placeholder
    mov rdi, 1                      ;
    lea rsi, [placeholer]           ;
    mov rdx, placeholerLen          ;
    syscall                         ;
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