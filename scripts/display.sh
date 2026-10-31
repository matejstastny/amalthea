#!/usr/bin/env bash
#@ display layout. gm45 drives two pipes fine, but see the note on geometry.

state="$HOME/.local/state/amalthea/display"
mkdir -p "$(dirname "$state")"

# names differ between the intel ddx (LVDS1, HDMI1) and modesetting
# (LVDS-1, HDMI-A-1), so never hardcode them
internal=$(xrandr --query | awk '/ connected/ && /^(LVDS|eDP)/ {print $1; exit}')
external=$(xrandr --query | awk '/ connected/ && /^(HDMI|DP|VGA)/ {print $1; exit}')

# best mode the external actually offers. the GM45's HDMI is limited to a
# 165 MHz TMDS clock, so a 4k panel negotiates down to 1920x1080 and the
# kernel does not even list the 4k modes - this picks whatever the top is
ext_mode=$(xrandr --query | awk -v o="$external" '
	$1 == o { f = 1; next }
	f && /^[A-Z]/ { exit }
	f && NF { print $1; exit }')

int_mode=$(xrandr --query | awk -v o="$internal" '
	$1 == o { f = 1; next }
	f && /^[A-Z]/ { exit }
	f && NF { print $1; exit }')

have_external() { [[ -n $external ]]; }

only_internal() {
	xrandr --output "$internal" --auto --primary --pos 0x0
	[[ -n $external ]] && xrandr --output "$external" --off
	echo laptop > "$state"
}

only_external() {
	xrandr --output "$external" --auto --primary --pos 0x0
	xrandr --output "$internal" --off
	echo external > "$state"
}

# stacked, not side by side, and that is deliberate: gen4 chips lose tiled
# framebuffers once the screen gets wider than the fence stride allows, which
# drops SNA back to an untiled buffer and makes every 2D op crawl. stacking
# keeps the width at the external's width instead of the sum of both.
extend() {
	local ew eh ix
	ew=${ext_mode%x*}
	eh=${ext_mode#*x}
	ix=$(( (ew - ${int_mode%x*}) / 2 ))
	(( ix < 0 )) && ix=0

	xrandr \
		--output "$external" --mode "$ext_mode" --pos 0x0 --primary \
		--output "$internal" --mode "$int_mode" --pos "${ix}x${eh}"
	echo extend > "$state"
}

side_by_side() {
	xrandr \
		--output "$internal" --mode "$int_mode" --pos 0x0 \
		--output "$external" --mode "$ext_mode" --pos "${int_mode%x*}x0" --primary
	echo side > "$state"
}

mirror() {
	xrandr --output "$internal" --auto --primary \
		--output "$external" --auto --same-as "$internal"
	echo mirror > "$state"
}

case "${1:-auto}" in
auto)     if have_external; then extend; else only_internal; fi ;;
extend)   have_external && extend ;;
side)     have_external && side_by_side ;;
external) have_external && only_external ;;
laptop)   only_internal ;;
mirror)   have_external && mirror ;;
status)
	printf 'internal: %s (%s)\nexternal: %s (%s)\nlayout:   %s\n' \
		"${internal:-none}" "${int_mode:-–}" "${external:-none}" "${ext_mode:-–}" \
		"$(cat "$state" 2>/dev/null || echo unset)"
	exit 0
	;;
menu)
	choice=$(printf '󰍹  extend (laptop under)\n󰍺  side by side\n󰌢  laptop only\n󰍹  external only\n󰁤  mirror\n' \
		| rofi -dmenu -i -p display -lines 5 -no-custom)
	case "$choice" in
	*"extend"*)       exec "$0" extend ;;
	*"side by side"*) exec "$0" side ;;
	*"laptop only"*)  exec "$0" laptop ;;
	*"external only"*) exec "$0" external ;;
	*mirror*)         exec "$0" mirror ;;
	*) exit 0 ;;
	esac
	;;
*) echo "usage: ${0##*/} [auto|extend|side|external|laptop|mirror|menu|status]" >&2; exit 1 ;;
esac

# the bar has to be rebuilt: polybar binds one instance per output
"$HOME/dotfiles/config/polybar/launch.sh"
"$HOME/dotfiles/scripts/wallpaper.sh" restore
