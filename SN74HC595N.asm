; This is code to be used with an ATTINY85 and a SN74HC595N. This allows the 
; ATTINY85 to send arbitrary bytes to the latch, which then displays them using
; LEDs. This could be extended to use two chained SN74HC595Ns to then display
; a 16 bit number.
; 
; Pin mapping:
; | ATTINY85 | SN74HC595N |
; | -------- | ---------- |
; | PINB0    | !SRCLR     |
; | PINB1    | SER        |
; | PINB3    | RCLK       |
; | PINB4    | SRCLK      |

    .include "tn85def.inc"

    .def    mask2       = r15        ; mask2 register
    .def    mask1       = r16        ; mask1 register
    .def    loop        = r17        ; data register
    .def    disp        = r18        ; data register

    .def    sleepL      = r23        ; sleep loop counter

    .def    sleepMsRl   = r24        ; sleep ms loop register low
    .def    sleepMsRh   = r25        ; sleep ms loop register high

    .equ    CLRB        = PINB0    
    .equ    SCLK        = PINB4        
    .equ    RCLK        = PINB3
    .equ    DATA        = PINB1

    .cseg
    .org    0x00

    ; set pins to output
    ldi     mask1,(1<<CLRB) | (1<<SCLK) | (1<<RCLK) | (1<<DATA)
    out     DDRB,mask1

    ; disable CLRB (HIGH), clear others
    ldi     mask1,(1<<CLRB)
    out     PORTB,mask1

    rcall   clear
    rcall   sleepOneSecond

    ldi     disp,0b10101010
    rcall   sendDisp
    rcall   showData
    rcall   sleepOneSecond

toggleLoop:
    ; check if the first bit in the display is currently 1
    ldi     mask1,0b10000000
    and     mask1,disp
    cpi     mask1,0b10000000
    ; if 1, clear the carry bit
    brne    clearC
    ; otherwise, set the carry bit
    bset    0
    rjmp    roll
clearC:
    bclr    0
roll:
    ; rotate left, using the carry bit
    rol     disp
    rcall   sendDisp
    rcall   showData
    rcall   sleepOneSecond
    rjmp    toggleLoop

clear:
    cbi     PORTB,CLRB
    rcall   sendData
    sbi     PORTB,CLRB
    rjmp    showData
    ret

sendDisp:
    ; we will loop over each bit in the byte
    ldi     loop,8
    ; copy the diplay value to a mask
    mov     mask2,disp
sdBit:
    ; check if the first bit is a 1 or 0
    ldi     mask1,0b10000000
    and     mask1,mask2
    cpi     mask1,0b10000000
    ; if not 1, send a zero
    brne    sdZero
    ; otherwise send a 1
    rcall   sendOne
    rjmp    sdNext
sdZero:
    rcall   sendZero
sdNext:
    ; shift left and send next bit
    lsl     mask2
    dec     loop
    brne    sdBit
    ret

sendZero:
    cbi     PORTB,DATA
    rjmp    sendData

sendOne:
    sbi     PORTB,DATA
    rjmp    sendData

sendData:
    sbi     PORTB,SCLK
    cbi     PORTB,SCLK
    ret

showData:
    sbi     PORTB,RCLK
    cbi     PORTB,RCLK
    ret

sleepOneSecond:
    ldi     sleepMsRh,0b00000011
    ldi     sleepMsRl,0b11101000
    rjmp    sleepMillis

; this assumes the clock is at 1MHz
; sleeps for N milliseconds (+3µs - timing is hard)
; N is defined by the values in sleepMsRh:sleepMsRl
; this means the max is 65535.003ms
sleepMillis:
; sleeps for 996µs
sleep996us:
    ldi     sleepL,0xF9
sleep996usLoop:
    nop
    dec     sleepL
    brne    sleep996usLoop

    sbiw    sleepMsRh:sleepMsRl,1
    brne    sleep996us
    ; extra clock cycles to make this even
    ret
