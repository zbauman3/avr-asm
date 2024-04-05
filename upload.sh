#!/bin/bash

avra -o init.hex init.asm && avrdude -c usbtiny -b 19200 -p attiny85 -U flash:w:init.hex