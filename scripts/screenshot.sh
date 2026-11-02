#!/usr/bin/env bash
#@ screenshot region

dir="$HOME/pictures/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%d_%H%M%S).png"

# accent-colored border, 2px, so the selection reads against a dark desktop
geom=$(slop -b 2 -c 0.435,0.580,0.675,1 -f '%g') || exit 1
[[ -z $geom ]] && exit 1

maim -u -g "$geom" "$file" || exit 1
xclip -selection clipboard -t image/png -i "$file"
notify-send "✦ screenshot" "region saved & copied" -t 2000
