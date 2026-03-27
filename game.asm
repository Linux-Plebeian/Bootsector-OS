org 0x7C00
video = 0x10
set_cursor_pos = 0x02
write_char = 0x0a
system_services = 0x15
wait_service = 0x86
kbd_int = 0x16
kbd_read = 0x00
keystroke_status = 0x01
kbd_left = 0x4B
kbd_right = 0x4D
kbd_up = 0x48
kbd_down = 0x50
kbd_space = 0x39
mov AH,00h      ; Set video mode
mov AL,03h      ; Mode 3 (Color text)
int video
mov AX, 0600h        ; AH=06(scroll up window), AL=00(entire window)
mov BH, 0x1E  ; left nibble for background, right nibble for foreground 
mov CX, 0x00        ; CH=00(top), CL=00(left)
mov DX, 0xFFFF       ; DH=255(bottom), DL=255(right)
int video
start:
    mov ah, wait_service    ;slight delay
    mov cx, 1              ;time to wait in 976 microseconds(1=976, 2=1952)
    mov dx, 0 
    int system_services
;======clear player===================
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 0
    int video
;============not player==============
;the house (spawn)
    mov ah, set_cursor_pos
    mov dh, 10       
    mov dl, 6          
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 8  
    int video
    mov ah, set_cursor_pos
    mov dh, 10       
    mov dl, 7       
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 8
    int video
    mov ah, set_cursor_pos
    mov dh, 10       
    mov dl, 8       
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 177
    int video

    mov ah, set_cursor_pos
    mov dh, 10       
    mov dl, 5       
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 177
    int video
    mov ah, set_cursor_pos
    mov dh, 9       
    mov dl, 6          
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 177  
    int video
    mov ah, set_cursor_pos
    mov dh, 9       
    mov dl, 7       
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 177
    int video
    mov ah, set_cursor_pos
    mov dh, 9       
    mov dl, 8       
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 177
    int video

    mov ah, set_cursor_pos
    mov dh, 9       
    mov dl, 5       
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, 177
    int video
;=============Player=================
    mov ah, set_cursor_pos
    mov dh, [pos_row]       
    mov dl, [pos_col]          
    mov bh, 0
    int video
    mov ah, write_char  
    mov bh, 0
    mov cx, 1    
    mov al, [player_char]   
    int video

;=================Keyboard===========
    mov ah, 1            ; BIOS get keyboard status int 16h AH 01h
    int kbd_int
    cbw                    ; Zero out AH in 1 byte
    int kbd_int        
    cmp ah, kbd_up        ; Check what key user entered...
    je kbd_scan_kbd_up
    cmp ah, kbd_down
    je kbd_scan_kbd_down
    cmp ah, kbd_left
    je kbd_scan_kbd_left
    cmp ah, kbd_right
    je kbd_scan_kbd_right
        cmp ah, kbd_space
    je kbd_scan_kbd_space
    kbd_scan_kbd_left:
        jne kbd_scan_kbd_right
        dec byte [pos_col]
        dec byte [block_col]  
        jmp start
    kbd_scan_kbd_right:
        jne kbd_scan_kbd_up
        inc byte [pos_col]
        inc byte [block_col]  
        jmp start
    kbd_scan_kbd_up:
        jne kbd_scan_kbd_down
        dec byte [pos_row]
        dec byte [block_row]   
        jmp start
    kbd_scan_kbd_down:
        jne kbd_scan_kbd_space
        inc byte [pos_row]  ;inc to increment byte, dec to decrement
        inc byte [block_row]   
        jmp start
    kbd_scan_kbd_space:
        jne start
        mov ah, set_cursor_pos
        mov dh, [block_row]     
        mov dl, [block_col]         
        mov bh, 0
        int video
        mov ah, write_char  
        mov bh, 0
        mov cx, 3   
        mov al, 177 
        int video
        inc byte [block]
pos_row: db 12
pos_col: db 12
block_row: db 12
block_col: db 12
block: db 12
player_char: db 0
times 510 -($-$$) db 0
dw 0xAA55 
