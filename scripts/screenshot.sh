#!/usr/bin/env bash
#@ screenshot region

dir="$HOME/pictures/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%d_%H%M%S).png"

# ember border, 2px, so the selection reads against a dark desktop
geom=$(slop -b 2 -c 0.769,0.455,0.353,1 -f '%g') || exit 1
[[ -z $geom ]] && exit 1

maim -u -g "$geom" "$file" || exit 1
xclip -selection clipboard -t image/png -i "$file"
notify-send "✦ screenshot" "region saved & copied" -t 2000
