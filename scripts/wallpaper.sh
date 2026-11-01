#!/usr/bin/env bash
#@ wallpaper picker / restore. feh, because a daemon is overkill for one image

dir="$HOME/wallpapers"
state="$HOME/.local/state/amalthea/wallpaper"
mkdir -p "$(dirname "$state")" "$dir"

# feh spreads a single image across the whole x screen, which on a stacked
# dual head means each monitor gets a different crop of it. passing the file
# once per output makes feh treat them as separate backgrounds instead.
set_bg() {
	local img="$1" n args=()
	n=$(xrandr --listmonitors 2>/dev/null | awk 'NR==1 {print $2}')
	[[ -z $n || $n -lt 1 ]] && n=1
	for ((i = 0; i < n; i++)); do args+=("$img"); done
	feh --no-fehbg --bg-fill "${args[@]}"
}

apply() {
	printf '%s\n' "$1" > "$state"
	set_bg "$1"
}

case "${1:-pick}" in
restore)
	if [[ -s $state ]] && [[ -f $(< "$state") ]]; then
		set_bg "$(< "$state")"
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
