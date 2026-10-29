#!/bin/bash
#NOTE: add check for sudo/doas, if neither use su

read -p "Keyboard brightness (0-100): " brightness
doas echo "${brightness}" > "/sys/class/leds/smc::kbd_backlight/brightness"
