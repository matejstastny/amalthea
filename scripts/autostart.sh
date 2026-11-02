#!/usr/bin/env bash
#@ everything the i3 session needs running; safe to re-run (i3 exec_always)

dots="$HOME/dotfiles"

# clipmenud and friends are shell scripts, so the process name is the
# interpreter and pgrep -x never matches - match the command line instead
once() {
	local pat="$1"; shift
	pgrep -f "$pat" >/dev/null || { "$@" >/dev/null 2>&1 & }
}

# notification daemon has to be up before anything that might notify.
# chromium-family browsers probe org.freedesktop.Notifications exactly once at
# startup and silently draw their own windows forever if nobody answers
once '^dunst' dunst
for _ in $(seq 1 50); do
	gdbus call --session --dest org.freedesktop.Notifications \
		--object-path /org/freedesktop/Notifications \
		--method org.freedesktop.Notifications.GetCapabilities >/dev/null 2>&1 && break
	sleep 0.1
done

once '^picom' picom --config "$HOME/.config/picom/picom.conf"
once clipmenud clipmenud
once xss-lock xss-lock --transfer-sleep-lock -- "$dots/scripts/lock.sh"
once polkit-gnome /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# displays, then the bar: polybar binds one instance per output, so it has to
# come after xrandr has settled
"$dots/scripts/display.sh" auto

# tray applets only after the bar owns the systray selection. started earlier
# they find no tray, exit 0 immediately, and look like they were never launched
for _ in $(seq 1 60); do
	xdotool search --class '[Pp]olybar' >/dev/null 2>&1 && break
	sleep 0.1
done
sleep 1
once nm-applet nm-applet --indicator
once blueman-applet blueman-applet

# input: match the asahi hyprland settings
xset r rate 190 30
xset s 600
for id in $(xinput list --id-only 2>/dev/null); do
	xinput set-prop "$id" "libinput Natural Scrolling Enabled" 1 2>/dev/null
	xinput set-prop "$id" "libinput Tapping Enabled" 1 2>/dev/null
	xinput set-prop "$id" "libinput Click Method Enabled" 0 1 2>/dev/null
	xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 2>/dev/null
done

# gtk apps read these, not the ini, when a settings daemon is absent
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark 2>/dev/null
gsettings set org.gnome.desktop.interface font-name "Terminess Nerd Font Mono 10" 2>/dev/null

once gnome-keyring-daemon gnome-keyring-daemon --start --components=secrets,pkcs11,ssh
