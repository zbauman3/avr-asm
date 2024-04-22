; Pin mapping:
; | ATTINY84 | SN74HC595N |
; | -------- | ---------- |
; | PINA0    | !SRCLR     |
; | PINA1    | SER        |
; | PINA2    | RCLK       |
; | PINA3    | SRCLK      |

    .include "tn84def.inc"

    .def    mask2       = r15        ; mask2 register
    .def    mask1       = r16        ; mask1 register
    .def    loop        = r17        ; data register
    .def    dispL       = r18        ; display low byte
    .def    dispH       = r19        ; display high byte

    .def    sleepL      = r23        ; sleep loop counter

    .def    sleepMsRl   = r24        ; sleep ms loop register low
    .def    sleepMsRh   = r25        ; sleep ms loop register high

    .equ    CLRB        = PINA0    
    .equ    SCLK        = PINA3        
    .equ    RCLK        = PINA2
    .equ    DATA        = PINA1

    .cseg
    .org    0x00

    ; set pins to output
    ldi     mask1,(1<<CLRB) | (1<<SCLK) | (1<<RCLK) | (1<<DATA)
    out     DDRA,mask1

    ; disable CLRB (HIGH), clear others
    ldi     mask1,(1<<CLRB)
    out     PORTA,mask1

    rcall   clear
    rcall   sleepOneSecond

wipeAll:
    ldi     dispH,0b00000000
    ldi     dispL,0b00000001
wipeAllLow:
    rcall   sendDisp
    ldi     sleepMsRh,0b00000000
    ldi     sleepMsRl,0b00001111
    rcall   sleepMillis
    cpi     dispL,0b10000000
    breq    wipeAllSetupHigh
    lsl     dispL
    rjmp    wipeAllLow

wipeAllSetupHigh:
    ldi     dispH,0b00000001
    ldi     dispL,0b00000000
wipeAllHigh:
    rcall   sendDisp
    ldi     sleepMsRh,0b00000000
    ldi     sleepMsRl,0b00001111
    rcall   sleepMillis
    cpi     dispH,0b10000000
    breq    wipeAll
    lsl     dispH
    rjmp    wipeAllHigh

clear:
    cbi     PORTA,CLRB
    rcall   sendData
    sbi     PORTA,CLRB
    rjmp    showData
    ret

sendDisp:
    ; we will loop over each bit in the byte
    ldi     loop,16
    ; copy the diplay value to a mask
    mov     mask2,dispH
sdBit:
    cpi     loop,8
    brne    sdComp
    mov     mask2,dispL
sdComp:
    ; check if the first bit is a 1 or 0
    ldi     mask1,0b10000000
    and     mask1,mask2
    cpi     mask1,0b10000000
    ; if not 1, send a zero
    brne    sdZero
    ; otherwise send a 1
    sbi     PORTA,DATA
    rcall   sendData
    rjmp    sdNext
sdZero:
    cbi     PORTA,DATA
    rcall   sendData
sdNext:
    ; shift left and send next bit
    lsl     mask2
    dec     loop
    brne    sdBit
    rjmp    showData

sendData:
    sbi     PORTA,SCLK
    cbi     PORTA,SCLK
    ret

showData:
    sbi     PORTA,RCLK
    cbi     PORTA,RCLK
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
