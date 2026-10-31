#!/usr/bin/env bash
#@ clipboard history

if ! pgrep -x clipmenud >/dev/null; then
	clipmenud >/dev/null 2>&1 &
	notify-send "󰅇  clipboard" "history daemon started, nothing recorded yet" -t 3000
	exit 0
fi

CM_LAUNCHER=rofi CM_HISTLENGTH=20 clipmenu -i -p clipboard -lines 10
