# amalthea - start the graphical session on tty1 and nowhere else
if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
	mkdir -p "$HOME/.local/state/amalthea"
	# -keeptty keeps the log on this vt instead of swallowing it, which is the
	# difference between "x did not come up" and knowing why
	exec startx -- -keeptty >"$HOME/.local/state/amalthea/startx.log" 2>&1
fi
