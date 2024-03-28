%include "common.inc"

section rom
    call initialize

    mov al, 'H'
    call out_char

    call power_off
