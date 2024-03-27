cpu 8086

video_seg   equ 0xb800
rom_seg     equ 0xf000

org (rom_seg * 0x10)

section video start=(video_seg * 0x10) nobits               ; video memory

video_off:
     db  16 dup (?)


section rom start=(rom_seg * 0x10)                          ; ROM

init:
    ; mov ax, video_seg
    ; mov es, ax

    ; mov byte [es:video_off + 0], 'H'
    ; mov byte [es:video_off + 1], 0x07

    xchg bx, bx

    jmp $

    ; position the boot entry point at 0xffff0
    ;times 0xfff0-($-$$) db 0
    db  0xfff0-($-$$) dup 0

boot:                                                       ; boot entry point
    jmp init

    ; fill in the rest of image up to 0xfffff
    db  0x10000-($-$$) dup 0
