#!/usr/bin/env bash
#@ wallpaper picker / restore. feh, because a daemon is overkill for one image

dir="$HOME/wallpapers"
state="$HOME/.local/state/amalthea/wallpaper"
mkdir -p "$(dirname "$state")" "$dir"

apply() {
	printf '%s\n' "$1" > "$state"
	feh --no-fehbg --bg-fill "$1"
}

case "${1:-pick}" in
restore)
	if [[ -s $state ]] && [[ -f $(< "$state") ]]; then
		feh --no-fehbg --bg-fill "$(< "$state")"
	else
		# no wallpaper yet: a flat base colour still looks deliberate
		hsetroot -solid "#16100f" 2>/dev/null || xsetroot -solid "#16100f"
	fi
	;;
pick)
	mapfile -t walls < <(find -L "$dir" -maxdepth 2 -type f \
		\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort)

	if [[ ${#walls[@]} -eq 0 ]]; then
		notify-send "󰸉  wallpaper" "no images in ~/wallpapers" -t 3000
		exit 1
	fi

	choice=$(printf '%s\n' "${walls[@]}" | sed "s|^$dir/||" \
		| rofi -dmenu -i -p wallpaper -lines 10)
	[[ -z $choice ]] && exit 0
	apply "$dir/$choice"
	;;
*)
	[[ -f $1 ]] && apply "$1"
	;;
esac
