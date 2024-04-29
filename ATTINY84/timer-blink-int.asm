    .include "tn84def.inc"

    .cseg
    .org    0x00
    rjmp    start
    .org    0x0B
    rjmp    timerOverflow

start:
    sbi     DDRB,PB2
    cbi     PORTB,PB2

    ldi     r17,0

    ldi     r16,0x00
    out     TCCR0A,r16

    ldi     r16,(1<<TOIE0)
    out     TIMSK0,r16

    sei

    ldi     r16,(1<<CS02) | (1<<CS00)
    out     TCCR0B,r16

doneLoop:
    rjmp    doneLoop

timerOverflow:
    cpi     r17,1
    brne    setOne
    cbi     PORTB,PB2
    ldi     r17,0
    rjmp    tovDone
setOne:
    sbi     PORTB,PB2
    ldi     r17,1
tovDone:
    reti
