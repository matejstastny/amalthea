#!/usr/bin/env bash
#@ screenshot the whole screen

dir="$HOME/pictures/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%d_%H%M%S).png"

maim -u "$file" || exit 1
xclip -selection clipboard -t image/png -i "$file"
notify-send "✦ screenshot" "screen saved & copied" -t 2000
