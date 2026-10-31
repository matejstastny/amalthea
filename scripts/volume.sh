#!/usr/bin/env bash
#@ volume control + osd

osd() { notify-send -a amalthea-osd -h "int:value:$1" "󰕾  $2" -t 1200; }

case "$1" in
up)
	pamixer --unmute --increase 5
	osd "$(pamixer --get-volume)" "$(pamixer --get-volume)%"
	;;
down)
	pamixer --unmute --decrease 5
	osd "$(pamixer --get-volume)" "$(pamixer --get-volume)%"
	;;
mute)
	pamixer --toggle-mute
	if [[ $(pamixer --get-mute) == true ]]; then
		notify-send -a amalthea-osd "󰝟  muted" -t 1200
	else
		osd "$(pamixer --get-volume)" "$(pamixer --get-volume)%"
	fi
	;;
micmute)
	pamixer --default-source --toggle-mute
	if [[ $(pamixer --default-source --get-mute) == true ]]; then
		notify-send -a amalthea-osd "󰍭  mic muted" -t 1200
	else
		notify-send -a amalthea-osd "󰍬  mic live" -t 1200
	fi
	;;
*) echo "usage: ${0##*/} up|down|mute|micmute" >&2; exit 1 ;;
esac
