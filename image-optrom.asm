cpu 8086

video_seg   equ 0xb800
rom_seg     equ 0xd000

rom_size    equ 0x4000

org (rom_seg * 0x10)

section video start=(video_seg * 0x10) nobits               ; video memory
     db  16 dup (?)


section rom start=(rom_seg * 0x10)                          ; ROM

    ; signature
    dw  0xaa55
    ; size in 512 byte blocks
    db  rom_size / 0x200

boot:                                                       ; entry point
    xchg bx, bx

    ; vga text mode
    mov ax, video_seg
    mov es, ax

    mov byte [es:0], 'H'
    mov byte [es:1], 0x07

    ; serial port
    mov dx, 0                                               ; COM1

    mov ah, 0x00                                            ; init serial port
    mov al, 0b_111_00_0_11                                  ; 9600 P0 S1 8 bits
    int 0x14

    mov ah, 0x01                                            ; send character
    mov al, 'H'
    int 0x14

    jmp $

    ; fill in the rest of image up to rom_size - 1
    db  rom_size-($-$$)-1 dup 0

    ; checksum
    db  0
