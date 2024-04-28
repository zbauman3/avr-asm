; Required constants
; | Name            | Usage                               |
; | --------------- | ----------------------------------- |
; | SN74HC595N_PORT | The PORTn that is being used for IO |
; | SN74HC595N_DDR  | The DDRn that is being used for IO  |
; | SN74HC595N_CLRB | The pin that attaches to !SRCLR     |
; | SN74HC595N_SCLK | The pin that attaches to SRCLK      |
; | SN74HC595N_RCLK | The pin that attaches to RCLK       |
; | SN74HC595N_DATA | The pin that attaches to SER        |

#ifndef _ZANE_SN74HC595N_
#define _ZANE_SN74HC595N_

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
    rcall   SN74HC595N_send
    sbi     SN74HC595N_PORT,SN74HC595N_CLRB
    rjmp    SN74HC595N_show
    ret

SN74HC595N_send:
    sbi     SN74HC595N_PORT,SN74HC595N_SCLK
    cbi     SN74HC595N_PORT,SN74HC595N_SCLK
    ret

SN74HC595N_show:
    sbi     SN74HC595N_PORT,SN74HC595N_RCLK
    cbi     SN74HC595N_PORT,SN74HC595N_RCLK
    ret

SN74HC595N_sendAndShow:
    sbi     SN74HC595N_PORT,SN74HC595N_SCLK
    cbi     SN74HC595N_PORT,SN74HC595N_SCLK
    sbi     SN74HC595N_PORT,SN74HC595N_RCLK
    cbi     SN74HC595N_PORT,SN74HC595N_RCLK
    ret

; Sends the byte located at r16 to the shift register
; Modifies: r16
SN74HC595N_sendByte:
    push    r17
    ; we will loop over each bit in the byte
    ldi     r17,8
SN74HC595N_sendByte_compare:
    sbrs    r16,7
    rjmp    SN74HC595N_sendByte_zero
SN74HC595N_sendByte_one:
    sbi     SN74HC595N_PORT,SN74HC595N_DATA
    rcall   SN74HC595N_send
    rjmp    SN74HC595N_sendByte_next
SN74HC595N_sendByte_zero:
    cbi     SN74HC595N_PORT,SN74HC595N_DATA
    rcall   SN74HC595N_send
SN74HC595N_sendByte_next:
    ; shift left and send next bit
    lsl     r16
    dec     r17
    brne    SN74HC595N_sendByte_compare
    pop     r17
    ret

#endif  /* _ZANE_SN74HC595N_ */