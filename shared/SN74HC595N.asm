; User-defined constants
; | Name            | Usage                               |
; | --------------- | ----------------------------------- |
; | SN74HC595N_CLRB | The pin that attaches to !SRCLR     |
; | SN74HC595N_RCLK | The pin that attaches to RCLK       |
;
; Library-defined constants
; | Name            | Usage                               | Value
; | --------------- | ----------------------------------- | ------------ |
; | SN74HC595N_PORT | The PORTn that is being used for IO | PORTA        |
; | SN74HC595N_DDR  | The DDRn that is being used for IO  | DDRA         |
; | SN74HC595N_SCLK | The pin that attaches to SRCLK      | PINA4 (USCK) |
; | SN74HC595N_DATA | The pin that attaches to SER        | PINA5 (DO)   |

#ifndef _ZANE_SN74HC595N_
#define _ZANE_SN74HC595N_

    ; .equ    SN74HC595N_CLRB     = ****
    ; .equ    SN74HC595N_RCLK     = ****
    .equ    SN74HC595N_PORT     = PORTA
    .equ    SN74HC595N_DDR      = DDRA
    .equ    SN74HC595N_SCLK     = PINA4
    .equ    SN74HC595N_DATA     = PINA5

SN74HC595N_setup:
    ; set pins to output
    sbi     SN74HC595N_DDR,SN74HC595N_CLRB
    sbi     SN74HC595N_DDR,SN74HC595N_SCLK
    sbi     SN74HC595N_DDR,SN74HC595N_RCLK
    sbi     SN74HC595N_DDR,SN74HC595N_DATA
    ; disable SN74HC595N_CLRB (HIGH), clear others
    sbi     SN74HC595N_PORT,SN74HC595N_CLRB
    cbi     SN74HC595N_PORT,SN74HC595N_SCLK
    cbi     SN74HC595N_PORT,SN74HC595N_RCLK
    cbi     SN74HC595N_PORT,SN74HC595N_DATA
    rcall   SN74HC595N_clear

SN74HC595N_clear:
    cbi     SN74HC595N_PORT,SN74HC595N_CLRB
    rcall   SN74HC595N_shift
    sbi     SN74HC595N_PORT,SN74HC595N_CLRB
    rjmp    SN74HC595N_show
    ret

SN74HC595N_shift:
    sbi     SN74HC595N_PORT,SN74HC595N_SCLK
    cbi     SN74HC595N_PORT,SN74HC595N_SCLK
    ret

SN74HC595N_show:
    sbi     SN74HC595N_PORT,SN74HC595N_RCLK
    cbi     SN74HC595N_PORT,SN74HC595N_RCLK
    ret

; Sends the byte located at r16 to the shift register
; This uses the USI in three-wire mode
SN74HC595N_sendByte:
    out     USIDR,r16
    push    r16
    push    r17
    ldi     r16,(1<<USIWM0)|(1<<USITC)
    ldi     r17,(1<<USIWM0)|(1<<USITC)|(1<<USICLK)
    out     USICR,r16 ; clock - MSB
    out     USICR,r17 ; shift
    out     USICR,r16
    out     USICR,r17
    out     USICR,r16
    out     USICR,r17
    out     USICR,r16
    out     USICR,r17
    out     USICR,r16
    out     USICR,r17
    out     USICR,r16
    out     USICR,r17
    out     USICR,r16
    out     USICR,r17
    out     USICR,r16
    out     USICR,r17
    pop     r17
    pop     r16
    rjmp    SN74HC595N_show

#endif  /* _ZANE_SN74HC595N_ */