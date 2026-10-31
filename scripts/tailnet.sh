#!/usr/bin/env bash
#@ tailnet picker - ssh into any online peer

mapfile -t rows < <(tailscale status --json 2>/dev/null \
	| jq -r '
		[.Self] + [.Peer // {} | .[]]
		| .[]
		| select(.DNSName != null)
		| "\(if .Online then "󰄬" else " " end) \(.HostName)\t\(.TailscaleIPs[0])"
	' 2>/dev/null)

if [[ ${#rows[@]} -eq 0 ]]; then
	notify-send "󰖂  tailnet" "tailscale is not up" -t 3000
	exit 1
fi

choice=$(printf '%s\n' "${rows[@]}" | column -t -s $'\t' \
	| rofi -dmenu -i -p tailnet -lines 10)
[[ -z $choice ]] && exit 0

host=$(awk '{print $2}' <<<"$choice")
[[ -z $host ]] && exit 1

# rmt knows the credentials for the hosts in ~/.config/remote/hosts.toml,
# plain ssh is the fallback for everything else
if command -v rmt >/dev/null && rmt --complete 2>/dev/null | grep -qxF "$host"; then
	alacritty -e rmt "$host"
else
	alacritty -e ssh "$host"
fi
