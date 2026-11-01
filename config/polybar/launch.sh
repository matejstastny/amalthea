#!/usr/bin/env bash
#@ (re)start polybar on every connected output

pkill -x polybar 2>/dev/null
# polybar refuses to bind a bar while the old one still holds the ipc socket
for _ in $(seq 1 50); do pgrep -x polybar >/dev/null || break; sleep 0.1; done

primary=$(xrandr --query | awk '/ connected primary/ {print $1; exit}')

for m in $(polybar --list-monitors | cut -d: -f1); do
	# only one bar may own the systray selection; hand it to the primary and
	# the others come up without a tray instead of logging a failed grab
	if [[ $m == "$primary" ]]; then
		MONITOR="$m" TRAY_POS=right polybar --reload main >/dev/null 2>&1 &
	else
		MONITOR="$m" TRAY_POS=none polybar --reload main >/dev/null 2>&1 &
	fi
done
