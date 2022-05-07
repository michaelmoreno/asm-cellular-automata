; terminal renderer of elementary cellular automata written in x86 assembly.

%include "utils.asm" ; import helper macros and subroutines

section  .data 
    prompt db 'Enter grid size: ', 0
    rulefound db 'Rule found: ', 0
    blankrow db '_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_',10,0 ; used to reset nextrow 
    lastrow  db 'x','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_',10,0
    nextrow  db '_','_','_','_','_','_','_','_','_','_','_','_','_','_','_','_',10,0
    neighborhood db 'h','h','h',0,0
    rules 
    ; db '_','x','_',
        ;   db 'x','x','_',
        ;   db 'x','_','x',
          db 'x','_','_',
        ;   db '_','x','x',
        ;   db '_','_','x',

section .bss
    gridsize: resb 16

section .text
    global _start

_start:
    ; call _matchRules
    ; write neighborhood
    ; write lastrow
    ; write lastrow
    mov r13, 0 ; number of generations
    jmp _generateRows

_generateRows:
    call _compareRows
    ; write nextrow
    call _makeLastRowNextRow
    inc r13
    cmp r13, 9 ; number of generations
    jne _generateRows
    jmp _exit

_makeLastRowNextRow:
    ; write lastrow
    mov rax, [nextrow]
    mov [lastrow], rax
    ; xor rax, rax
    mov rax, [blankrow]
    mov [nextrow], rax
    ret


_compareRows:
    mov r11, 0 ; cell index
    ; push r11 ; save cell index
_compareRowsLoop:
    ; write neighborhood
    cmp r11, 13; check if we're at the last cell
    je _compareRowsLoopEnd
    mov r9b, [lastrow+r11-1] ; get left relative
    mov r12b, [lastrow+r11] ; get center relative
    mov r15b, [lastrow+r11+1] ; get right relative
    ; put relative cells in neighborhood
    mov [neighborhood], r9b ; set left neighbor
    mov [neighborhood+1], r12b ; set center neighbor
    mov [neighborhood+2], r15b ; set right neighbor

    call _matchRules
    inc r11 ; increment cell index
    jmp _compareRowsLoop
    
_compareRowsLoopEnd:
    ret

_matchRules:
    mov rdx, 0 ; rules index
    mov rcx, 0 ; neighborhood index
    mov r14, 3 ; neighborhood size
    xor rax, rax ; reset rax
    xor rbx, rbx ; reset rbx
_matchRulesLoop:
    cmp rdx, 8 ; check if we're at the last rule
    jge _noRuleMatched ; if we're at the last rule, jump to no match
    cmp rcx, 3 ; if neighborhood index is 3, all cells passed
    je _ruleMatched ; if all cells passed, jump to rule matched
    mov al, byte [neighborhood+rcx] ; get current cell in neighborhood
    mov bl, [rules+rdx] ; get current cell in rules
    inc rcx ; increment neighborhood index
    inc rdx ; increment rules index
    cmp al, bl ; compare neighborhood cello with rule cell
    je _matchRulesLoop ; if matched, jump to loop to compare next cells

    ; if match fails, skip to next rule and reset neighborhood index
    sub r14, rcx ; get distance away from next rule
    add rdx, r14, ; offset rules index by distance
    mov rcx, 0 ; reset neighborhood index
    mov r14, 3 ; reset neighborhood size to avoid eventual negative values
    jmp _matchRulesLoop ; restart loop

_noRuleMatched:
    ret
_ruleMatched:
    mov byte [nextrow+r11], 0x78 ; set cell in next row to 'x'
    mov rax, [nextrow] ; set next row to next row
    ret



_exit:
    mov rax, 60 ; exit
    mov rdi, 0 ; status
    syscall