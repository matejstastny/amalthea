#!/usr/bin/env bash
#@ wifi picker

notify() { notify-send "󰤨  wifi" "$1" -t 3000; }

if [[ $(nmcli -t -f WIFI radio) != enabled ]]; then
	nmcli radio wifi on && notify "radio on, scanning…"
	sleep 2
fi

nmcli device wifi rescan >/dev/null 2>&1

# the ssid goes last on each line so it can be recovered with a single cut,
# even when it contains spaces
list=$(nmcli -t -e yes -f ACTIVE,SIGNAL,SECURITY,SSID device wifi list \
	| awk -F: '
		{ gsub(/\\:/, ":", $4) }
		$4 == "" { next }
		!seen[$4]++ {
			mark = ($1 == "yes") ? "󰄬" : " "
			sec  = ($3 == "" || $3 == "--") ? "󰦞" : "󰌾"
			printf "%s %s %3s%%  %s\n", mark, sec, $2, $4
		}')

[[ -z $list ]] && { notify "no networks found"; exit 1; }

choice=$(printf '%s\n󰖪  turn wifi off\n󰑓  open nmtui\n' "$list" \
	| rofi -dmenu -i -p wifi -lines 10)
[[ -z $choice ]] && exit 0

case "$choice" in
*"turn wifi off") nmcli radio wifi off; notify "radio off"; exit 0 ;;
*"open nmtui")    alacritty -e nmtui; exit 0 ;;
esac

ssid=${choice#*%  }
[[ -z $ssid || $ssid == "$choice" ]] && exit 1

# a saved profile connects without asking for anything
if nmcli -t -f NAME connection show | grep -qxF "$ssid"; then
	if nmcli connection up id "$ssid" >/dev/null 2>&1; then
		notify "connected to $ssid"
	else
		notify "could not connect to $ssid"
	fi
	exit
fi

pass=$(rofi -dmenu -password -i -p "$ssid" -lines 0)
if [[ -z $pass ]]; then
	nmcli device wifi connect "$ssid" >/dev/null 2>&1
else
	nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1
fi

if [[ $? -eq 0 ]]; then
	notify "connected to $ssid"
else
	notify "could not connect to $ssid"
fi
