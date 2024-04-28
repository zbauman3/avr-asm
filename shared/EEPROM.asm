#ifndef _ZANE_EEPROM_
#define _ZANE_EEPROM_

; Writes the data in R16 to the EEPROM address held in XH:XL
EEPROM_write:
    push    r17
    ; Wait for completion of previous write
    sbic    EECR, EEPE
    rjmp    EEPROM_write
    ; Set Programming mode
    ldi     r17, (0<<EEPM1)|(0<<EEPM0)
    out     EECR, r17
    ; Set up address registers
    out     EEARH, XH
    out     EEARL, XL
    ; Write data (r19) to data register
    out     EEDR, r16
    ; Write logical one to EEMPE
    sbi     EECR, EEMPE
    ; Start eeprom write by setting EEPE
    sbi     EECR, EEPE
    pop     r17
    ret

; Reads data from the EEPROM address held in XH:XL to r16
EEPROM_read:
    ; Wait for completion of previous write
    sbic    EECR, EEPE
    rjmp    EEPROM_read
    ; Set up address registers
    out     EEARH, XH
    out     EEARL, XL
    ; Start eeprom read by writing EERE
    sbi     EECR, EERE
    ; Read data from data register
    in      r16, EEDR
    ret

#endif  /* _ZANE_EEPROM_ */