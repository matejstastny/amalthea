#!/usr/bin/env bash
#@ backlight control + osd

case "$1" in
# 5%- rather than a flat step: the bottom of this panel's range is useful
up)   brightnessctl set 5%+ -q ;;
down) brightnessctl set 5%- -q ;;
*) echo "usage: ${0##*/} up|down" >&2; exit 1 ;;
esac

pct=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
notify-send -a amalthea-osd -h "int:value:$pct" "󰃞  ${pct}%" -t 1200
