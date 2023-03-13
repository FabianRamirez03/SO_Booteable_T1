org 0x7C00
bits 16

start:
    ; Initialize stack pointer
    xor ax, ax
    mov ss, ax
    mov sp, 0x7c00
    
    ; Load boot sector into memory
    mov bx, 0x8000 ; Destination address
    mov dl, 0x80   ; USB drive number (may need to be changed)
    mov dh, 0      ; Head number
    mov cx, 1      ; Sector number
    mov ah, 0x02   ; BIOS read sector function
    mov al, 1      ; Number of sectors to read
    int 0x13       ; Call BIOS disk I/O function
    jc boot_error  ; Jump to error handling if read fails

    ; Jump to start of loaded program
    jmp 0x8000

boot_error:
    ; Display error message and halt
    mov ah, 0x0E ; BIOS print function
    mov al, 'E'  ; Error code
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, '!'
    int 0x10
    hlt
    jmp $

; Pad boot sector to 512 bytes
times 510-($-$$) db 0
dw 0xAA55     ; Boot sector signature