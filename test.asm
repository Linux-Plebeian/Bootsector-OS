org 0x7C00
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

main_loop:
    mov si, input_buffer
    call print_prompt

read_loop:
    call get_key
    cmp al, 0x0D          ; Enter
    je  process_input

    cmp al, 0x08          ; Backspace
    je  backspace

    mov [si], al
    inc si
    call print_char
    jmp read_loop

backspace:
    cmp si, input_buffer
    je read_loop
    dec si
    mov al, 0x08
    call print_char
    mov al, ' '
    call print_char
    mov al, 0x08
    call print_char
    jmp read_loop

; --------------------------
; PROCESS INPUT
; --------------------------
process_input:
    mov byte [si], 0      ; Null terminate

    call newline
    call check_command

    call clear_buffer
    jmp main_loop

; --------------------------
; STRING CHECKER
; --------------------------
check_command:
    mov si, input_buffer
    mov di, cmd_hello
    call strcmp
    cmp ax, 1
    je do_hello

    mov si, input_buffer
    mov di, cmd_clear
    call strcmp
    cmp ax, 1
    je do_clear

    ; Unknown command
    mov si, msg_unknown
    call print_string
    ret

; --------------------------
; COMMAND FUNCTIONS
; --------------------------
do_hello:
    mov si, msg_hello
    call print_string
    ret

do_clear:
    call clear_screen
    ret

; --------------------------
; STRING COMPARE
; AX = 1 if equal, 0 if not
; --------------------------
strcmp:
.next:
    lodsb              ; AL = [SI]
    mov bl, [di]
    inc di

    cmp al, bl
    jne .not_equal

    cmp al, 0
    je .equal

    jmp .next

.equal:
    mov ax, 1
    ret

.not_equal:
    mov ax, 0
    ret

; --------------------------
; CLEAR BUFFER
; --------------------------
clear_buffer:
    mov di, input_buffer
    mov cx, 128
    mov al, 0
.rep:
    stosb
    loop .rep
    ret

; --------------------------
; HELPERS
; --------------------------
print_prompt:
    mov si, prompt
    call print_string
    ret

print_string:
.next:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .next
.done:
    ret

print_char:
    mov ah, 0x0E
    int 0x10
    ret

get_key:
    xor ah, ah
    int 0x16
    ret

newline:
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char
    ret

clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10
    ret

; --------------------------
; DATA
; --------------------------
prompt      db '> ', 0
msg_unknown db 'Unknown command', 0
msg_hello   db 'Hello!', 0

cmd_hello   db 'hello', 0
cmd_clear   db 'clear', 0

input_buffer times 128 db 0

; --------------------------
; BOOT SIGNATURE
; --------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
