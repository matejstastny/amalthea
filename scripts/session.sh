#!/usr/bin/env bash
#@ launch or close the standard app set

# name | pgrep -x | i3 class | command
apps=(
	"terminal|alacritty|Alacritty|alacritty"
	"browser|firefox|firefox|firefox"
)

running() { pgrep -x "$1" >/dev/null; }

start_apps() {
	local name proc class cmd
	for app in "${apps[@]}"; do
		IFS='|' read -r name proc class cmd <<<"$app"
		running "$proc" && continue
		setsid -f $cmd >/dev/null 2>&1
	done
}

close_apps() {
	local name proc class cmd
	for app in "${apps[@]}"; do
		IFS='|' read -r name proc class cmd <<<"$app"
		i3-msg "[class=\"^${class}$\"] kill" >/dev/null 2>&1
	done
}

case "${1:-start}" in
start) start_apps ;;
close) close_apps ;;
*) echo "usage: ${0##*/} [start|close]" >&2; exit 1 ;;
esac
