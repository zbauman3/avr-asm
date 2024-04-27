
#ifndef _ZANE_UTIL_
#define _ZANE_UTIL_

; this assumes the clock is at 1MHz
; sleeps for N milliseconds (+7µs - timing is hard)
; N is defined by the values in XH:XL
; this means the max is 65535.007ms
sleepMillis:
    push    r16
sleep996us:
    ldi     r16,0xF9
sleep996usLoop:
    nop
    dec     r16
    brne    sleep996usLoop
    sbiw    XH:XL,1
    brne    sleep996us
    pop     r16
    ret


#endif  /* _ZANE_UTIL_ */