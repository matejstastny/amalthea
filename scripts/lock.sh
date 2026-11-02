#!/usr/bin/env bash
#@ lock the screen

pgrep -x i3lock >/dev/null && exit 0

# i3lock-color, not stock i3lock: the stock unlock ring is hardcoded green and
# red, which is the one thing on this machine that cannot be themed otherwise.
# colours are rrggbbaa, so they carry an alpha byte the palette file does not.
base=0a0a0b
surface=16181b
muted=3a3e44
dim=8b9097
text=e4e6e9
ember=6f94ac
amber=9fb0ba
rust=b3555a

i3lock \
	--nofork \
	--ignore-empty-password \
	--show-failed-attempts \
	--color="$base" \
	--clock \
	--indicator \
	--radius=90 \
	--ring-width=6 \
	--inside-color="${surface}cc" \
	--ring-color="${muted}ff" \
	--insidever-color="${surface}cc" \
	--ringver-color="${amber}ff" \
	--insidewrong-color="${surface}cc" \
	--ringwrong-color="${rust}ff" \
	--line-uses-inside \
	--keyhl-color="${ember}ff" \
	--bshl-color="${rust}ff" \
	--separator-color="${base}00" \
	--verif-color="${text}ff" \
	--wrong-color="${rust}ff" \
	--modif-color="${amber}ff" \
	--layout-color="${dim}ff" \
	--date-color="${dim}ff" \
	--time-color="${text}ff" \
	--verif-text="checking" \
	--wrong-text="nope" \
	--noinput-text="" \
	--lock-text="locking" \
	--lockfailed-text="lock failed" \
	--time-str="%H:%M" \
	--date-str="%a %d %b" \
	--time-font="Iosevka Nerd Font" \
	--date-font="Iosevka Nerd Font" \
	--layout-font="Iosevka Nerd Font" \
	--verif-font="Iosevka Nerd Font" \
	--wrong-font="Iosevka Nerd Font" \
	--time-size=32 \
	--date-size=14 \
	--verif-size=14 \
	--wrong-size=14 \
	--pass-media-keys \
	--pass-volume-keys
