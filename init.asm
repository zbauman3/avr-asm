	.include "tn85def.inc"

	.def	mask 	= r16		; mask register
	.def	ledR 	= r17		; led register
	.def	oLoopR 	= r18		; outer loop register
	.def	iLoopRl = r24		; inner loop register low
	.def	iLoopRh = r25		; inner loop register high

	.equ	oVal 	= 71		; outer loop value
	.equ	iVal 	= 28168		; inner loop value

	.cseg
	.org	0x00

	cli			     ; disable interrupts
	ldi	mask,(1<<CLKPCE)
	out	CLKPR,mask
	ldi	mask,0b00000000
	out	CLKPR,mask
	sei			     ; enabled interrupts
	
	clr	ledR			; clear led register
	ldi	mask,(1<<PINB0)		; load 00000001 into mask register
	out	DDRB,mask		; set PINB0 to output

start:	eor	ledR,mask		; toggle PINB0 in led register
	out	PORTB,ledR		; write led register to PORTB

	ldi	oLoopR,oVal		; initialize outer loop count

oLoop:	ldi	iLoopRl,LOW(iVal)	; intialize inner loop count in inner
	ldi	iLoopRh,HIGH(iVal)	; loop high and low registers

iLoop:	sbiw	iLoopRl,1		; decrement inner loop registers
	brne	iLoop			; branch to iLoop if iLoop registers != 0

	dec	oLoopR			; decrement outer loop register
	brne	oLoop			; branch to oLoop if outer loop register != 0

	rjmp	start			; jump back to start