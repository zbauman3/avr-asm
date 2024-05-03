    .include "tn84def.inc"

    .equ    SN74HC595N_PORT     = PORTA
    .equ    SN74HC595N_DDR      = DDRA
    .equ    SN74HC595N_CLRB     = PINA0    
    .equ    SN74HC595N_SCLK     = PINA3        
    .equ    SN74HC595N_RCLK     = PINA2
    .equ    SN74HC595N_DATA     = PINA1

    .cseg
    .org    0x00
    rjmp    start
    .org    0x09
    rjmp    TIM0_COMPA
    .org    0x11

start:
    rcall   SN74HC595N_setup
    rcall   SN74HC595N_clear
    rcall   setupMillis

loopIt:
    rcall   getMillis

    ; mov     r16,r14
    ; rcall   SN74HC595N_sendByte
    ; mov     r16,r13
    ; rcall   SN74HC595N_sendByte
    ; rcall   SN74HC595N_show
    ; ldi     XH,0b00000000
    ; ldi     XL,0b00001111
    ; rcall   sleepMillis

    mov     r16,r12
    rcall   SN74HC595N_sendByte
    mov     r16,r11
    rcall   SN74HC595N_sendByte
    rcall   SN74HC595N_show
    ldi     XH,0b00000000
    ldi     XL,0b00001111
    rcall   sleepMillis

    rjmp    loopIt

getMillis:
    mov     r11,r15
    in      r12,GPIOR0
    in      r13,GPIOR1
    in      r14,GPIOR2
    ret

; uses r15, GPIOR0, GPIOR1, GPIOR2
setupMillis:
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

TIM0_COMPA:
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


.include "./shared/sleep-1MHz.asm"
.include "./shared/SN74HC595N.asm"
