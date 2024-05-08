; These helpers provide a method for getting how many milliseconds have passed
; since the machine started running. This stores the data in 32 bits, so the 
; value will roll over every ~4,294,967 seconds, or ~49.7 days.
;
; This uses the 8-bit Timer/Counter0 in MODE=2 with OCR0A=121 and clk/8.
; The "get" function outputs the 4 bytes to r13:r15.
;
; To use these helpers, you must:
; 1. Point the TIM0_COMPA interrupt vector to `MILLIS_interrupt`.
; 2. Call the `MILLIS_setup` subroutine at the beginning of the program.
; 3. Call `MILLIS_get` whenever you want the current state of the counter.
;
; Example Usage:
;
;     .cseg
;     .org    0x00
;     rjmp    start
;     .org    0x09
;     rjmp    MILLIS_interrupt
;     .org    0x11
; 
; start:
;     rcall   MILLIS_setup
; 
; mainLoop:
;     rcall   MILLIS_get
;     ; do something here with r13:r15
;     rjmp    mainLoop

#ifndef _ZANE_MILLIS_
#define _ZANE_MILLIS_

    .equ    MILLIS_DH     = 0x00
    .equ    MILLIS_DL     = 0x60

; This gets the current millis and places the 4 bytes into r13:r15
MILLIS_get:
    push    XH
    push    XL
    ldi     XH,MILLIS_DH
    ldi     XL,MILLIS_DL
    cli
    ld      r12,X+
    ld      r13,X+
    ld      r14,X+
    ld      r15,X
    sei
    pop     XL
    pop     XH
    ret

; This sets up everything that is needed for the millis to work
MILLIS_setup:
    push    XH
    push    XL
    push    r16
    ; clear RAM
    ldi     XH,MILLIS_DH
    ldi     XL,MILLIS_DL
    ldi     r16,0
    st      X+,r16
    st      X+,r16
    st      X+,r16
    st      X,r16
    ; use OCRA
    ldi     r16,(1<<WGM01)
    out     TCCR0A,r16
    ; clk/8
    ldi     r16,(1<<CS01)
    out     TCCR0B,r16
    ; set the TOP to 120. 120 / (1MHz / 8) = 0.96 µs. This gives the interrupt
    ; handler enough clock cycles to handle the change, and 1 additional cycle for
    ; triggering the interrupt
    ldi     r16,120
    out     OCR0A,r16
    ; enable overflow interrupts
    sei
    ldi     r16,(1<<OCIE0A)
    out     TIMSK0,r16
    pop     r16
    pop     XL
    pop     XH
    ret

; This handles the interrupt and increments the counter
MILLIS_interrupt:
    push    r0
    push    r16
    push    XH
    push    XL
    ldi     XH,MILLIS_DH
    ldi     XL,MILLIS_DL
    ; get the first byte from flash, add 1 to it, then store it
    ldi     r16,1
    ld      r0,X
    add     r0,r16
    st      X+,r0
    ; add 0 with carry to the next 3 bytes
    ldi     r16,0
    ld      r0,X
    adc     r0,r16
    st      X+,r0
    ld      r0,X
    adc     r0,r16
    st      X+,r0
    ld      r0,X
    adc     r0,r16
    st      X,r0
    pop     XL
    pop     XH
    pop     r16
    pop     r0
    ; stall for time
    nop
    nop
    nop
    reti

#endif  /* _ZANE_MILLIS_ */