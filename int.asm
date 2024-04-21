    .include "tn85def.inc"

    .def    mask    = r16        ; mask register
    .def    ledR    = r17        ; led register
    .def    oLoopR  = r18        ; outer loop register
    .def    countR  = r19        ; outer loop length register
    .def    pbState = r20        ; read interrupt state
    .def    iLoopRl = r24        ; inner loop register low
    .def    iLoopRh = r25        ; inner loop register high

    .equ    sOVal   = 71
    .equ    qOVal   = 20
    .equ    iVal    = 28168      ; inner loop value

    .cseg
    .org    0x00
    rjmp    start
    .org    0x02
    rjmp    isr

start:
    ; output on PB0, input on PB3
    ldi     countR,sOVal
    ldi     mask,(1<<PB0)
    out     DDRB,mask

    ; LOW on PB0, pullup on PB3
    ldi     mask,(1<<PB3)
    out     PORTB,mask

    ; setup interrupts on PB3
    sei
    ldi     mask,(1<<PCIE)
    out     GIMSK,mask
    ldi     mask,(1<<PCINT3)
    out     PCMSK,mask

    clr     ledR

setOLoop:
    ; setout outer loop value
    mov     oLoopR,countR

    ; logic to toggle the LED
    ldi     mask,0x01
    eor     ledR,mask
    brne    ledOn

    ; if not branching, turn LED off
    cbi     PORTB,PB0
    rjmp    setILoop

ledOn:
    sbi     PORTB,PB0

setILoop:
    ; reset the inner loop value
    ldi     iLoopRl,LOW(iVal)
    ldi     iLoopRh,HIGH(iVal)

loop:
    ; inner loop
    sbiw    iLoopRh:iLoopRl,1
    brne    loop

    ; outer loop
    dec     oLoopR
    brne    setILoop
    rjmp    setOLoop

isr:
    ; read button state
    in      pbState,PINB
    andi    pbState,0b00001000
    ; if not pressed, do nothing
    brne    leaveIsr

    ; subtract quick val from current count
    ; then toggle the count speed depending on its
    ; current value
    subi    countR,qOVal
    brne    quickCount

    ldi     countR,sOVal
    rjmp    leaveIsr

quickCount:
    ldi     countR,qOVal

leaveIsr:
    reti