    .include "tn84def.inc"

    .equ    SN74HC595N_CLRB     = PINA0
    .equ    SN74HC595N_RCLK     = PINA2

    .cseg
    .org    0x00
    rjmp    start
    .org    0x09
    rjmp    MILLIS_interrupt
    .org    0x11

start:
    rcall   MILLIS_setup
    rcall   SN74HC595N_setup
    rcall   SN74HC595N_clear

loopIt:
    rcall   MILLIS_get

    rcall   SN74HC595N_clear
    mov     r16,r14
    rcall   SN74HC595N_sendByte
    mov     r16,r13
    rcall   SN74HC595N_sendByte
    rcall   SN74HC595N_show
    ldi     XH,0b00000000
    ldi     XL,0b00001000
    rcall   SLEEP_millis

    rjmp    loopIt

.include "./shared/sleep-1MHz.asm"
.include "./shared/millis-1MHz.asm"
.include "./shared/SN74HC595N.asm"
