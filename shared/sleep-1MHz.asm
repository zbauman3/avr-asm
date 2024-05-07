
#ifndef _ZANE_SLEEP_
#define _ZANE_SLEEP_


; This sleeps for N milliseconds where N = XH:XL. This works at 1MHz.
; The timing accounts for an extra 5 clock cycles needed for loading data into
; XH:XL and calling rjmp. So once this is called, it will sleep for Nms - 5µs.
SLEEP_millis:
    push    r16
    ; remove 1 so that we can use the extra cycles for setup
    sbiw    XH:XL,1
    ; if only sleeping for 1, skip to make up the extra cycles
    breq    SLEEP_millis_makeup
    nop     ; even timing
; the main sleep loop - each loop is 1ms
SLEEP_millis_mainOuter:
    ldi     r16,249
SLEEP_millis_mainInner:
    nop
    dec     r16
    brne    SLEEP_millis_mainInner
    sbiw    XH:XL,1
    brne    SLEEP_millis_mainOuter
    nop     ; even timing
; this makes up the extra clock cycles that were lost to setup
SLEEP_millis_makeup:
    ldi     r16,245
    nop
    nop
    nop
SLEEP_millis_makeupLoop:
    nop
    dec     r16
    brne    SLEEP_millis_makeupLoop
; cleanup
    pop     r16
    ret

#endif  /* _ZANE_SLEEP_ */