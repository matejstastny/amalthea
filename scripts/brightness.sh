#!/usr/bin/env bash
#@ backlight control + osd

# this panel's acpi_video0 exposes 16 levels, so percentage steps round away to
# nothing - move it one hardware level at a time instead
case "$1" in
up)   brightnessctl set +1 -q ;;
down) brightnessctl set 1- -q ;;
*) echo "usage: ${0##*/} up|down" >&2; exit 1 ;;
esac

read -r cur max < <(brightnessctl -m | awk -F, '{print $3, $5}')
pct=$(( cur * 100 / max ))
notify-send -a amalthea-osd -h "int:value:$pct" "󰃞  ${pct}%" -t 1200
