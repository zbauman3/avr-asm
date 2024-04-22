#!/bin/bash

if [ $# -eq 0 ];
then
	echo "Enter a script name (i.e. \"init\" for \"init.asm\")";
	exit 1;
fi

avra -o out.hex $1.asm && avrdude -c usbtiny -b 19200 -p atmega1284 -U flash:w:out.hex
