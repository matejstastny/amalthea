#!/bin/sh
# amalthea - xinitrc. no display manager: zprofile runs startx on tty1 login,
# which keeps a whole daemon and its pam stack off a two-core machine.

[ -f /etc/X11/xinit/.Xresources ] && xrdb -merge /etc/X11/xinit/.Xresources
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# systemd user units (and anything dbus-activated) need these in their
# environment or they come up with no display and quietly fall over
systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY 2>/dev/null

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=gtk3
# gm45 tops out at gl 2.1, so firefox has to use software webrender; left on
# auto it probes, fails, and falls back with a stutter on every start
export MOZ_WEBRENDER=0
export LIBGL_DRI3_DISABLE=0

exec i3
