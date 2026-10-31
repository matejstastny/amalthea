#!/usr/bin/env bash
#@ bluetooth picker

notify() { notify-send "󰂯  bluetooth" "$1" -t 3000; }

if ! bluetoothctl show >/dev/null 2>&1; then
	notify "no adapter"; exit 1
fi

powered=$(bluetoothctl show | awk '/Powered:/ {print $2}')
if [[ $powered != yes ]]; then
	bluetoothctl power on >/dev/null && notify "powered on, scanning…"
	bluetoothctl --timeout 5 scan on >/dev/null 2>&1
fi

list=$(bluetoothctl devices | while read -r _ mac name; do
	if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
		printf '󰄬 %s\t%s\n' "$name" "$mac"
	else
		printf '  %s\t%s\n' "$name" "$mac"
	fi
done)

choice=$(printf '%s\n󰂲  power off\n󰑓  scan again\n󰒓  open blueman\n' "$list" \
	| column -t -s $'\t' | rofi -dmenu -i -p bluetooth -lines 10)
[[ -z $choice ]] && exit 0

case "$choice" in
*"power off")   bluetoothctl power off >/dev/null; notify "powered off"; exit 0 ;;
*"scan again")  bluetoothctl --timeout 8 scan on >/dev/null 2>&1; exec "$0" ;;
*"open blueman") blueman-manager & exit 0 ;;
esac

mac=$(grep -oE '([0-9A-F]{2}:){5}[0-9A-F]{2}' <<<"$choice")
[[ -z $mac ]] && exit 1

if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
	bluetoothctl disconnect "$mac" >/dev/null && notify "disconnected"
else
	bluetoothctl pair "$mac" >/dev/null 2>&1
	bluetoothctl trust "$mac" >/dev/null 2>&1
	bluetoothctl connect "$mac" >/dev/null 2>&1 \
		&& notify "connected" || notify "could not connect"
fi
