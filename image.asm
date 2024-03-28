%include "common.inc"

section rom
    call initialize

    call dump_state

    mov al, 'H'
    ;call out_char

    call dump_state

    call power_off
