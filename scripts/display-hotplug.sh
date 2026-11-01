#!/bin/sh
#@ run from udev (via a systemd oneshot) when a drm connector changes state

# the session, not the caller: udev runs this as root with no X at all
ipid=$(pgrep -x i3 | head -1)
[ -z "$ipid" ] && exit 0

user=$(stat -c %U "/proc/$ipid")
home=$(getent passwd "$user" | cut -d: -f6)
[ -z "$home" ] && exit 0

xpid=$(pgrep -x Xorg | head -1)
auth=$(tr '\0' '\n' < "/proc/$xpid/cmdline" 2>/dev/null | grep -m1 serverauth)
[ -z "$auth" ] && auth="$home/.Xauthority"
[ -r "$auth" ] || exit 0

# the connector state is not settled the instant udev fires; xrandr run too
# early reports the old topology and the layout comes out wrong
sleep 2

su "$user" -c "DISPLAY=:0 XAUTHORITY='$auth' '$home/dotfiles/scripts/display.sh' auto" >/dev/null 2>&1
