#!/usr/bin/env bash
#@ polybar: tailnet state

if ! systemctl is-active --quiet tailscaled; then
	echo "TS off"
	exit 0
fi

state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null)
case "$state" in
Running)
	peers=$(tailscale status --json 2>/dev/null | jq -r '[.Peer // {} | .[] | select(.Online)] | length' 2>/dev/null)
	echo "TS ${peers:-0}"
	;;
NeedsLogin) echo "TS login" ;;
Stopped)    echo "TS stopped" ;;
*)          echo "TS -" ;;
esac
