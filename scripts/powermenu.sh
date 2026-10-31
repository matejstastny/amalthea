#!/usr/bin/env bash
#@ power menu

choice=$(printf '%s\n' \
	"󰌾  lock" \
	"󰍃  log out" \
	"󰒲  suspend" \
	"󰜉  reboot" \
	"󰐥  shut down" \
	| rofi -dmenu -i -p power -lines 5 -no-custom)

case "$choice" in
*lock)     "$HOME/dotfiles/scripts/lock.sh" ;;
*"log out") i3-msg exit ;;
*suspend)  systemctl suspend ;;
*reboot)   systemctl reboot ;;
*"shut down") systemctl poweroff ;;
esac
