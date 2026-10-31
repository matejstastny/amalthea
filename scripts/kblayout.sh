#!/usr/bin/env bash
#@ toggle between the us and cz layouts (same pair as asahi)

current=$(setxkbmap -query | awk '/^layout:/ {print $2}')

if [[ $current == us ]]; then
	setxkbmap -layout cz -variant qwerty
	notify-send "󰌌  keyboard" "cz (qwerty)" -t 1500 -a amalthea-osd
else
	setxkbmap -layout us
	notify-send "󰌌  keyboard" "us" -t 1500 -a amalthea-osd
fi

# setxkbmap resets the repeat rate
xset r rate 190 30
