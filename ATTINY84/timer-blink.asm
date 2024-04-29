    .include "tn84def.inc"

    .cseg
    .org    0x00
    rjmp    start

start:
    sbi     DDRB,PB2
    cbi     PORTB,PB2

    ldi     r16,(1<<COM0A0)
    out     TCCR0A,r16

    ldi     r16,(1<<CS02) | (1<<CS00)
    out     TCCR0B,r16

doneLoop:
    rjmp    doneLoop