cpu 8086

video_seg   equ 0xb800
rom_seg     equ 0xd000

rom_size    equ 0x4000

org (rom_seg * 0x10)

section video start=(video_seg * 0x10) nobits               ; video memory

video_off:
     db  16 dup (?)


section rom start=(rom_seg * 0x10)                          ; ROM

    ; signature
    dw  0xaa55
    ; size in 512 byte blocks
    db  rom_size / 0x200

boot:                                                       ; entry point
    ; mov ax, video_seg
    ; mov es, ax

    ; mov byte [es:video_off + 0], 'H'
    ; mov byte [es:video_off + 1], 0x07

    xchg bx, bx

    jmp $

    ; fill in the rest of image up to rom_size - 1
    db  rom_size-($-$$)-1 dup 0

    ; checksum
    db  0
