org 0x7C00             ; BIOS loads boot sector here
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov si, input_buffer  ; Where to store typed characters
    call print_prompt

read_loop:
    call get_key
    cmp al, 0x0D          ; Enter key
    je  done_typing
    cmp al, 0x08          ; Backspace
    je  handle_backspace

    ; Store typed character
    mov [si], al
    inc si

    ; Echo character to screen
    call print_char
    jmp read_loop

handle_backspace:
    cmp si, input_buffer
    je  read_loop          ; Don't backspace past start
    dec si
    mov al, 0x08
    call print_char
    mov al, ' '
    call print_char
    mov al, 0x08
    call print_char
    jmp read_loop

done_typing:
    ; Null-terminate string
    mov byte [si], 0

    ; Print newline
    mov al, 0x0D
    call print_char
    mov al, 0x0A
    call print_char

    ; Print message
    mov si, message
    call print_string

    ; Print what was typed
    mov si, input_buffer
    call print_string

hang:
    jmp hang

; --------------------------
; BIOS Helpers
; --------------------------

print_prompt:
    mov si, prompt
    call print_string
    ret

print_string:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp print_string
.done:
    ret

print_char:
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    ret

get_key:
    xor ah, ah
    int 0x16
    ret

; --------------------------
; Data
; --------------------------
prompt      db 'Type something: ', 0
message     db 'You typed: ', 0
input_buffer times 128 db 0

; --------------------------
; Boot Signature
; --------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
