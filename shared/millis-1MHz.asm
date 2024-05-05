; These helpers provide a method for getting how many milliseconds have passed
; since the machine started running. This stores the data in 32 bits, so the 
; value will roll over every ~4,294,967 seconds, or ~49.7 days.
;
; This uses the 8-bit Timer/Counter0 in MODE=2 with OCR0A=121 and clk/8.
; The millisecond counter is stored in r15, GPIOR0, GPIOR1, and GPIOR2.
; The "get" function outputs the 4 bytes to r11:r14.
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
;     ; do something here with r11:r14
;     rjmp    mainLoop

#ifndef _ZANE_MILLIS_
#define _ZANE_MILLIS_

; This gets the current millis and places the 4 bytes into r11:r14
MILLIS_get:
    cli
    mov     r11,r15
    in      r12,GPIOR0
    in      r13,GPIOR1
    in      r14,GPIOR2
    sei
    ret

; This sets up everything that is needed for the millis to work
MILLIS_setup:
    push    r16
    ; clear stuff
    ldi     r16,0
    mov     r15,r16
    out     GPIOR0,r16
    out     GPIOR1,r16
    out     GPIOR2,r16
    ; use OCRA
    ldi     r16,(1<<WGM01)
    out     TCCR0A,r16
    ; clk/8
    ldi     r16,(1<<CS01)
    out     TCCR0B,r16
    ; set the TOP to 121. 121 / (1MHz / 8) = 0.968 µs. This gives the interrupt
    ; handler enough clock cycles to handle the change, and 1 additional cycle for
    ; triggering the interrupt
    ldi     r16,121
    out     OCR0A,r16
    ; enable overflow interrupts
    sei
    ldi     r16,(1<<OCIE0A)
    out     TIMSK0,r16
    pop     r16
    ret

; This handles the interrupt and increments the counter
MILLIS_interrupt:
    push    r0
    push    r16
    ; increment r15
    ldi     r16,1
    add     r15,r16
    ; increment GPIOR0, with carry
    ldi     r16,0
    in      r0,GPIOR0
    adc     r0,r16
    out     GPIOR0,r0
    ; increment GPIOR1, with carry
    in      r0,GPIOR1
    adc     r0,r16
    out     GPIOR1,r0
    ; increment GPIOR2, with carry
    in      r0,GPIOR2
    adc     r0,r16
    out     GPIOR2,r0
    ; cleanup
    pop     r16
    pop     r0
    ; extra for timing
    nop
    nop
    nop
    nop
    reti

#endif  /* _ZANE_MILLIS_ */