cpu 8086


section .text start=0xf0000              ; boot

; position the boot code at 0xffff0
times 0xfff0 db 0

loop:
    jmp loop

; fill in the rest of image up to 0xfffff
times 0x10000-($-$$) db 0
