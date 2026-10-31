#!/usr/bin/env bash
#@ polybar: tailnet state

if ! systemctl is-active --quiet tailscaled; then
	echo "󰖂 off"
	exit 0
fi

state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null)
case "$state" in
Running)
	peers=$(tailscale status --json 2>/dev/null | jq -r '[.Peer // {} | .[] | select(.Online)] | length' 2>/dev/null)
	echo "󰖂 ${peers:-0}"
	;;
NeedsLogin) echo "󰖂 login" ;;
Stopped)    echo "󰖂 stopped" ;;
*)          echo "󰖂 –" ;;
esac
