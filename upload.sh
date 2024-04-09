#!/bin/bash

# Set clock speed to 16MHz
# avrdude -v -pattiny85 -cusbtiny -B8 -e -Ulfuse:w:0b11110011:m

# Set clock speed to 8MHz
# avrdude -v -pattiny85 -cusbtiny -B8 -e -Ulfuse:w:0b11100010:m

if [ $# -eq 0 ];
then
	echo "Enter a script name (i.e. \"init\" for \"init.asm\")";
	exit 1;
fi

avra -o out.hex $1.asm && avrdude -c usbtiny -b 19200 -p attiny85 -U flash:w:out.hex
