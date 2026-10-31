#!/usr/bin/env bash
#@ lock the screen

source "$HOME/.config/amalthea/palette.sh"

pgrep -x i3lock >/dev/null && exit 0

i3lock \
	--nofork \
	--ignore-empty-password \
	--show-failed-attempts \
	--color="$AM_BASE_RAW"
