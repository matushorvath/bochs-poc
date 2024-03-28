%include "common.inc"

section rom
    dump_state

    mov al, 'H'
    ;call out_char

    dump_state

    call power_off
