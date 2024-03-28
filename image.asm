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
    ; bochs breakpoint
    ;xchg bx, bx

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

wait_serial:
    mov ax, 0x03                                            ; get status
    int 0x14

    and ah, 0b_01000000                                     ; trans shift reg empty
    jz wait_serial

    ; bochs console
    mov al, 'H'
    out 0xe9, al

    ; apm connect
    mov ax, 0x5301
    xor bx, bx
    int 0x15

    ; apm set version to 1.2
    mov ax, 0x530e
    xor bx, bx
    mov cx, 0x0102
    int 0x15

    ; apm power off
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

    ; reset using keyboard controller
    ;mov al, 0xfe                                            ; shutdown command
    ;out 0x64, al                                            ; write to 8042 status port

    jmp $

    ; fill in the rest of image up to rom_size - 1
    db  rom_size-($-$$)-1 dup 0

    ; checksum
    db  0
