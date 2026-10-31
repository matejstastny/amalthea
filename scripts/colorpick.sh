#!/usr/bin/env bash
#@ pick a colour off the screen and copy the hex (hyprpicker -a equivalent)

eval "$(xdotool getmouselocation --shell)"

hex=$(maim -u -g "1x1+${X}+${Y}" /dev/stdout 2>/dev/null \
	| magick - -format '%[hex:p{0,0}]' info: 2>/dev/null)

[[ -z $hex ]] && { notify-send "✦ colour" "could not read a pixel" -t 2000; exit 1; }

printf '#%s' "${hex,,}" | xclip -selection clipboard
notify-send "✦ colour" "#${hex,,} copied" -t 2500
