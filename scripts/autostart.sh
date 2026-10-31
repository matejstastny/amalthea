#!/usr/bin/env bash
#@ everything the i3 session needs running; safe to re-run (i3 exec_always)

dots="$HOME/dotfiles"
source "$HOME/.config/amalthea/palette.sh"

# one-shot: things that must not be started twice
once() {
	pgrep -x "$1" >/dev/null || { shift; "$@" >/dev/null 2>&1 & }
}

# notification daemon has to be up before anything that might notify.
# chromium-family browsers probe org.freedesktop.Notifications exactly once at
# startup and silently draw their own windows forever if nobody answers
once dunst dunst
for _ in $(seq 1 50); do
	gdbus call --session --dest org.freedesktop.Notifications \
		--object-path /org/freedesktop/Notifications \
		--method org.freedesktop.Notifications.GetCapabilities >/dev/null 2>&1 && break
	sleep 0.1
done

once picom picom --config "$HOME/.config/picom/picom.conf"
once clipmenud clipmenud
once xss-lock xss-lock --transfer-sleep-lock -- "$dots/scripts/lock.sh"
once nm-applet nm-applet --indicator
once blueman-applet blueman-applet
once polkit-gnome-authentication-agent-1 /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# displays first: the bar binds one instance per output, so it has to come
# after xrandr has settled
"$dots/scripts/display.sh" auto

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
gsettings set org.gnome.desktop.interface font-name "Iosevka Nerd Font 10" 2>/dev/null

once gnome-keyring-d gnome-keyring-daemon --start --components=secrets,pkcs11,ssh
