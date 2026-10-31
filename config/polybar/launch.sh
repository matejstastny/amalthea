#!/usr/bin/env bash
#@ (re)start polybar on every connected output

pkill -x polybar 2>/dev/null
# polybar refuses to bind a bar while the old one still holds the ipc socket
while pgrep -x polybar >/dev/null; do sleep 0.2; done

if command -v polybar-msg >/dev/null; then
	polybar-msg cmd quit >/dev/null 2>&1
fi

for m in $(polybar --list-monitors | cut -d: -f1); do
	MONITOR="$m" polybar --reload main >/dev/null 2>&1 &
done
