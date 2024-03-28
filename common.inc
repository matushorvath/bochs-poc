%ifndef BOCHS
%ifndef VM8086
    %error "Neither BOCHS nor VM8086 was defined."
%endif
%endif


rom_seg     equ 0xd000
rom_addr    equ (rom_seg * 0x10)
rom_size    equ 0x4000


cpu 8086
org rom_addr


section rom start=rom_addr
    ; option rom signature, needed for booting in bochs
    dw  0xaa55                                              ; signature
    db  rom_size / 0x200                                    ; size in 512 byte blocks

init:

%ifdef BOCHS
section rom_end start=(rom_addr + rom_size - 1)
    ; dummy section to make sure the binary is exactly rom_size bytes long
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
