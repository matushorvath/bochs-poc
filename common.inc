%ifndef BOCHS
%ifndef VM8086
    %error "Neither BOCHS nor VM8086 was defined."
%endif
%endif


rom_seg     equ 0xd000
rom_addr    equ (rom_seg * 0x10)
rom_size    equ 0x3000

util_seg    equ 0xd300
util_addr   equ (util_seg * 0x10)
util_size   equ 0x1000

code_size   equ rom_size + util_size


cpu 8086
org rom_addr


; startup and initialization

section rom start=rom_addr
    ; option rom signature, needed for booting in bochs
    dw  0xaa55                                              ; signature
    db  code_size / 0x200                                   ; size in 512 byte blocks
init:


%ifdef BOCHS
section image_end start=(rom_addr + code_size - 1)
    ; dummy section to make sure the image is exactly rom_size bytes long
    db  0
%endif


%ifdef VM8086
boot_addr   equ 0xffff0

section boot start=boot_addr
    ; the CPU starts here at ffff:0000
    jmp init

    ; to have a round file size, fill the image up to 0x100000
    db  (0x100000 - boot_addr) - ($ - $$) dup 0
%endif


; utilities

section util start=util_addr

initialize:
%ifdef BOCHS
    push ax
    push dx

    ; initialize COM1
    mov ah, 0x00                                            ; init serial port
    mov dx, 0                                               ; COM1
    mov al, 0b_111_00_0_11                                  ; 9600 P0 S1 B8
    int 0x14

    pop dx
    pop ax
%endif

    ret


out_char:                                                   ; al is the char to print
%ifdef BOCHS
    push ax
    push dx

    ; send character to COM1
    mov ah, 0x01                                            ; send character
    mov dx, 0                                               ; COM1
    int 0x14

.wait_serial:
    ; TODO mov ah, 0x03
    mov ax, 0x03                                            ; get status
    int 0x14

    and ah, 0b_01000000                                     ; trans shift reg empty
    ; TODO jnz %wait_serial
    jz .wait_serial

    pop dx
    pop ax
%endif

%ifdef VM8086
    ; TODO
%endif

    ret


power_off:
%ifdef BOCHS
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
%endif

%ifdef VM8086
    ; TODO
%endif

    ; we should not ever get here
    jmp $
