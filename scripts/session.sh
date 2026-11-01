#!/usr/bin/env bash
#@ launch or close the standard app set

# name | pgrep -x | i3 class | workspace | command
apps=(
	"terminal|alacritty|Alacritty|1|alacritty"
	"browser|firefox|firefox|3|firefox"
)

running() { pgrep -x "$1" >/dev/null; }

start_apps() {
	local name proc class ws cmd
	for app in "${apps[@]}"; do
		IFS='|' read -r name proc class ws cmd <<<"$app"
		running "$proc" && continue
		# place it explicitly: there is no blanket assign rule for the
		# terminal, by design
		i3-msg "workspace number $ws" >/dev/null 2>&1
		setsid -f $cmd >/dev/null 2>&1
		sleep 1
	done
	i3-msg "workspace number 1" >/dev/null 2>&1
}

close_apps() {
	local name proc class ws cmd
	for app in "${apps[@]}"; do
		IFS='|' read -r name proc class ws cmd <<<"$app"
		i3-msg "[class=\"^${class}$\"] kill" >/dev/null 2>&1
	done
}

case "${1:-start}" in
start) start_apps ;;
close) close_apps ;;
*) echo "usage: ${0##*/} [start|close]" >&2; exit 1 ;;
esac
