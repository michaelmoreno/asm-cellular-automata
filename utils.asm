%macro write 1
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, %1 ; buffer address
    call _getLength
    syscall
%endmacro

%macro read 2
    mov rax, 0 ; read
    mov rdi, 0 ; stdin
    mov rsi, %1 ; buffer address
    mov rdx, %2 ; buffer size
    syscall
    replaceChar %1, 10, 0
%endmacro

%macro replaceChar 3
    mov rdi, %1 ; buffer address
    mov al, %2 ; char to replace
    mov ah, %3 ; char to replace with
    repne scasb ; search for char
    mov [rdi-1], ah ; set new char
%endmacro

%macro appendChar 2
    mov rdi, %1 ; buffer address
    mov al, 0 ; null terminator
    mov ah, %2 ; char to append
    repne scasb ; search for null terminator
    mov [rdi-1], ah ; set null terminator
%endmacro

%macro replaceString 2
    mov rsi, %1 ; address of string to be replaced
    mov rdi, %2 ; address of string to replace with
    call _replaceStringLoop
%endmacro
_replaceStringLoop:
    mov byte al, [rdi] ; get char to replace with
    mov [rsi], byte al ; replace char
    inc rsi ; set address to next char to replace
    inc rdi ; set address to next char to replace with
    cmp byte [rsi], 10 ; check for newline
    jne _replaceStringLoop ; if not newline, continue
    ret ; return to caller location

_getLength:
    push rsi ; save buffer address
    mov rdx, 0 ; counter
_lengthLoop:
    inc rdx ; increment counter
    inc rsi ; increment rsi
    cmp byte [rsi], 0 ; check if current character is 0 (end of string)
    jne _lengthLoop ; loop
    pop rsi ; restore buffer address
    ret ; return to caller location

