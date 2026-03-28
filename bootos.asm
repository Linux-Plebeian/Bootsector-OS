org 0x7C00

video = 0x10
key_backspace = 0x08

system_services = 0x15
wait_service = 0x86

keyboard_int = 0x16


start:

    ; Print newline
    mov ah, 0x0E
    mov al, 0x0D
    int video
    mov al, 0x0A
    int video

    ;print arrow
    mov ah, 0x0E
    mov al, 0x0D
    int video
    mov al, 16
    int video

    xor cl, cl
    mov di, char_buffer

    .loop:
        mov ah, 0
        int keyboard_int
        cmp al, key_backspace
        je .backspace
        cmp al, 0x0D
        je .done
        cmp cl, 0xFF           ; limit input to 255 characters
        jae .loop

        mov ah, 0x0E
        int video

        stosb
        inc cl
        jmp .loop

    .backspace:
        cmp cl, 0
        je .loop
        dec di
        mov byte [di], 0
        dec cl

        mov ah, 0x0E
        mov al, key_backspace
        int video
        mov al, ' '
        int video
        mov al, key_backspace
        int video
        jmp .loop

    .done:
        mov al, 0
        stosb

        mov si, char_buffer
        mov di, hlt_str
        call compare_str
        jc .matched_hlt

        mov si, char_buffer
        mov di, help_str
        call compare_str
        jc .matched_help

        mov si, char_buffer
        mov di, inc_str
        call compare_str
        jc .matched_inc

        mov si, char_buffer
        mov di, dec_str
        call compare_str
        jc .matched_dec

        mov si, char_buffer
        mov di, color_str
        call compare_str
        jc .matched_color

        mov si, char_buffer
        mov di, ascii_str
        call compare_str
        jc .fill_ascii

        mov si, char_buffer
        mov di, start_OS_str
        call compare_str
        jc .start_kernel



        ; invalid command
        jmp start
    ;hlt
    .matched_hlt:
        mov ah, 0x0E
        mov si, 0x21
    .print_hlt:
        lodsb
        or al, al
        jz .halt
        int video
        jmp .print_hlt
    .halt:
        cli
        hlt
        jmp $

    ;help cmd
    .matched_help:
        mov ah, 0x0E
        mov si, help_msg
    .print_help:
        lodsb
        or al, al
        jz start
        int video
        jmp .print_help


    ;inc command
    .matched_inc:
        mov ah, 0x0E
        mov al, 0x0D
        int video
        mov al, 0x0A
        int video
        inc byte [var]
        mov ah, 0x0E
        mov si, var
    .print_var:
        lodsb
        or al, al
        jz start
        int video
        jmp .print_var

    ;dec command
    .matched_dec:
        mov ah, 0x0E
        mov al, 0x0D
        int video
        mov al, 0x0A
        int video
        dec byte [var]
        mov ah, 0x0E
        mov si, var
    .print_var1:
        lodsb
        or al, al
        jz start
        int video
        jmp .print_var

    ;color command
    .matched_color:
        mov AH,00h      ; Set video mode
        mov AL,03h      ; Mode 3 (Color text)
        int video
        mov AX, 0600h   ; AH=06(scroll up window), AL=00(entire window)
        inc BH          ;change color
        mov CX, 0x00    ; CH=00(top), CL=00(left)
        mov DX, 0xFFFF  ; DH=255(bottom), DL=255(right)
        int video
        jmp start

    ;fill screen
    .fill_ascii:
        mov ah, wait_service
        mov cx, 1
        mov dx, 0
        int system_services
        ; Print newline
        mov ah, 0x0E
        mov al, 0x0D
        int video
        mov al, 0x0A
        int video
        inc byte [char]
        mov ah, 0x0E
        mov si, char
        lodsb
        or al, al
        jz start
        int video
        jmp .fill_ascii
    start_kernel:
    ;TODO insert jump to kernel here
;----------------------------------
; compare_str: compares SI to DI
; Returns carry flag set (JC) if equal
compare_str:
    .compare_loop:
        lodsb
        mov bl, [di]
        inc di
        cmp al, bl
        jne .not_equal
        cmp al, 0
        jne .compare_loop
        stc         ; match
        ret
    .not_equal:
        clc         ; no match
        ret



char_buffer: times 10 db 67
hlt_str:    db 'hlt',0
help_str:   db 'help',0
inc_str:    db 'inc',0
dec_str:    db 'dec',0
color_str:  db 'clr', 0
ascii_str:  db 'ascii',0
start_OS_str:  db 'start_OS',0


help_msg:   db 0x0D,0x0A, 'hlt,help,inc,dec,clr,ascii,start_OS', 0
var:        db 0x30
char:       db 0x00
;help_msg:   db 0x0D


times 510 - ($ - $$) db 0
dw 0xAA55
