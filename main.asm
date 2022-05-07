; terminal renderer of elementary cellular automata written in x86 assembly.

%include "utils.asm" ; import helper macros and subroutines

section  .data 
    prompt db 'Enter grid size: ', 0
    rulefound db 'Rule found: ', 0
    lastrow db 'o','o','o','x','o','o','o',10,0
    nextrow db 'o','o','o','o','o','o','o',10,0
    window db 'x','x','x',0
    rules db 'o','o','o', 'h','o','o',0
    
section .bss
    gridsize: resb 16

section .text
    global _start

_start:
    call _matchRules
    jmp _exit

_matchRules:
    mov rdx, 0 ; rules index
    cmp rcx, 0 ; neighborhood index
    mov r14, 3 ; neighborhood size
_matchRulesLoop:
    cmp rcx, 3 ; if neighborhood index is 3, all cells passed
    je _ruleMatched ; if all cells passed, jump to rule matched
    mov al, byte [window+rcx] ; get current cell in neighborhood
    mov bl, [rules+rdx] ; get current cell in rules
    inc rcx ; increment neighborhood index
    inc rdx ; increment rules index
    cmp al, bl ; compare neighborhood cello with rule cell
    je _matchRulesLoop ; if matched, jump to loop to compare next cells

    ; if match fails, skip to next rule and reset neighborhood index
    sub r14, rcx ; get distance away from next rule
    add rdx, r14, ; offset rules index by distance
    mov rcx, 0 ; reset neighborhood index
    jmp _matchRulesLoop ; restart loop

_ruleMatched:
    write rulefound
    ret

_exit:
    mov rax, 60 ; exit
    mov rdi, 0 ; status
    syscall