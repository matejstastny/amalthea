#!/usr/bin/env bash
#@ (re)start polybar on every connected output

# a layout change fires the udev hotplug hook, which calls this, while the
# script that made the change is also calling it - without a lock the two
# interleave between the pkill and the relaunch and you end up with two bars
# per output
# a fixed path, not XDG_RUNTIME_DIR: the udev hook runs through su without it
exec 9>"/tmp/amalthea-polybar-$(id -u).lock"
flock 9

pkill -x polybar 2>/dev/null
# polybar refuses to bind a bar while the old one still holds the ipc socket
for _ in $(seq 1 50); do pgrep -x polybar >/dev/null || break; sleep 0.1; done

for m in $(polybar --list-monitors | cut -d: -f1); do
	# no tray: nm-applet/blueman-applet icons never matched the theme, and
	# wifi/bluetooth already have their own rofi menus (alt+n, alt+b) plus a
	# click on the NET module, so the tray had nothing worth keeping
	#
	# 9>&- closes the lock fd in this background child before it execs.
	# polybar is long-running, so without this it inherits fd 9 and holds
	# the flock for as long as it's alive - meaning every run after the
	# first deadlocks forever waiting for a lock a dead script no longer
	# needs but a live polybar is still unknowingly sitting on.
	MONITOR="$m" TRAY_POS=none polybar --reload main 9>&- >/dev/null 2>&1 &
done

# hold the lock until the bars have actually bound, or a second caller races
# straight back into the pkill above
sleep 1
