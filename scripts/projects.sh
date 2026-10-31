#!/usr/bin/env bash
#@ project picker - open a repo in nvim (the asahi alt+p, minus vscode)

roots=("$HOME/devel" "$HOME/dotfiles" "$HOME/notes")

mapfile -t projects < <(
	for r in "${roots[@]}"; do
		[[ -d $r ]] || continue
		if [[ -d $r/.git ]]; then
			printf '%s\n' "$r"
		else
			find "$r" -mindepth 1 -maxdepth 2 -type d -name .git -printf '%h\n' 2>/dev/null
		fi
	done | sort -u
)

[[ ${#projects[@]} -eq 0 ]] && { notify-send "󰙅  projects" "nothing under ${roots[*]}" -t 3000; exit 1; }

choice=$(printf '%s\n' "${projects[@]}" | sed "s|^$HOME|~|" \
	| rofi -dmenu -i -p project -lines 10)
[[ -z $choice ]] && exit 0

dir="${choice/#\~/$HOME}"
[[ -d $dir ]] || exit 1

alacritty --working-directory "$dir" -e nvim
