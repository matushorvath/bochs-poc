%include "common.inc"

section rom

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
