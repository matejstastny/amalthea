#!/usr/bin/env bash
#@ amalthea bootstrap - idempotent, safe to re-run
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log()  { printf '\033[38;2;196;116;90m::\033[0m %s\n' "$1"; }
warn() { printf '\033[38;2;201;160;94m!!\033[0m %s\n' "$1"; }
err()  { printf '\033[38;2;168;85;64mxx\033[0m %s\n' "$1" >&2; }

[[ $EUID -eq 0 ]] && { err "run as your user, not root (it will sudo where needed)"; exit 1; }

# packages -------------------------------------------------------------------

pkgs=(
	# xorg
	xorg-server xorg-xinit xorg-xrandr xorg-xinput xorg-xprop xorg-xset
	xorg-xkill xorg-xdpyinfo xorg-xrdb xf86-input-libinput
	# gen4 intel: sna is hand-written 2d, glamor needs a gl this chip lacks
	xf86-video-intel mesa libva-intel-driver libva-utils

	# session
	i3-wm picom polybar rofi dunst xss-lock feh numlockx
	maim slop xclip xdotool wmctrl imagemagick clipmenu rofimoji
	papirus-icon-theme gnome-themes-extra adwaita-icon-theme

	# fonts
	# terminus: bitmap-derived, no ligatures, cheaper to rasterize than a
	# vector face - matches the ter-116n console font below
	ttf-terminus-nerd
	noto-fonts noto-fonts-emoji

	# terminal + shell
	alacritty tmux zsh zsh-autosuggestions zsh-syntax-highlighting
	starship zoxide eza fzf ripgrep fd bat btop yazi lazygit
	neovim git github-cli jq trash-cli fastfetch man-db man-pages
	# the nvim config pins clangd to the system binary, not mason's
	clang
	# mason installs its js-based language servers with npm; nothing else here
	# uses it. note bun will not run on this cpu at all - no sse4.2.
	nodejs npm
	wget curl unzip p7zip rsync openssh less tree python

	# audio
	pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
	pamixer pulsemixer pavucontrol playerctl

	# net + bluetooth
	networkmanager network-manager-applet bluez bluez-utils blueman tailscale

	# laptop
	tlp tlp-rdw brightnessctl acpi powertop zram-generator

	# desktop integration
	polkit polkit-gnome gnome-keyring xdg-utils xdg-user-dirs
	xdg-desktop-portal xdg-desktop-portal-gtk gsettings-desktop-schemas
	dex libnotify gtk3 gtk4

	# apps
	# falkon: QtWebEngine, so modern sites render fine, but a lighter native
	# chrome than Firefox and it is called out as a solid pick on GL 2.1
	falkon zathura zathura-pdf-mupdf mpv
)

log "syncing and upgrading"
sudo pacman -Syu --noconfirm --needed || { err "pacman -Syu failed"; exit 1; }

log "installing ${#pkgs[@]} packages"
sudo pacman -S --noconfirm --needed "${pkgs[@]}" || warn "some packages failed, see above"

# things that only live in the aur, all installed best-effort since paru may
# not exist yet on a fresh box
# i3lock-color replaces stock i3lock: the stock unlock ring is hardcoded
# green and red and is the one thing here that cannot otherwise be themed
# vesktop-bin: Discord client with Vencord (themes/plugins) built in, prebuilt
# so no compile time on this cpu
# vscodium-bin: prebuilt, telemetry-stripped vscode; patched below for
# marketplace access and the system font
aur=(ps_mem scc gitmux i3lock-color vesktop-bin vscodium-bin)
if command -v paru >/dev/null; then
	log "installing aur extras (${aur[*]})"
	paru -S --noconfirm --needed --skipreview "${aur[@]}" 2>/dev/null \
		|| warn "aur extras failed; they are optional"
else
	warn "paru not found, skipping aur extras"
fi

# system config --------------------------------------------------------------

log "pacman: colour and parallel downloads"
sudo sed -i -e 's/^#Color$/Color/' -e 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf

log "makepkg: -j2, this cpu has two cores"
sudo sed -i -e 's/^#\?MAKEFLAGS=.*/MAKEFLAGS="-j2"/' /etc/makepkg.conf

log "xorg.conf.d -> dotfiles"
sudo mkdir -p /etc/X11/xorg.conf.d
for f in "$root"/config/xorg/*.conf; do
	sudo ln -sfn "$f" "/etc/X11/xorg.conf.d/$(basename "$f")"
done

log "zram swap (25% of ram, ahead of the disk swap)"
sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'EOF'
[zram0]
zram-size = ram / 4
compression-algorithm = zstd
swap-priority = 100
EOF

log "logind: lid closes to suspend"
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/amalthea.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
HandlePowerKey=poweroff
IdleAction=ignore
EOF

log "console: readable font on a 1366x768 panel"
sudo tee /etc/vconsole.conf >/dev/null <<'EOF'
KEYMAP=us
FONT=ter-116n
EOF
sudo pacman -S --noconfirm --needed terminus-font >/dev/null 2>&1

# services -------------------------------------------------------------------

log "enabling services"
for s in NetworkManager sshd tailscaled bluetooth tlp systemd-timesyncd; do
	sudo systemctl enable --now "$s" >/dev/null 2>&1 || warn "could not enable $s"
done
sudo systemctl enable fstrim.timer >/dev/null 2>&1
# tlp wants these out of the way or it fights them over the radios
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket >/dev/null 2>&1

systemctl --user enable --now pipewire pipewire-pulse wireplumber >/dev/null 2>&1 \
	|| warn "pipewire user units not enabled (no user session?)"

# user ------------------------------------------------------------------------

if [[ $SHELL != */zsh ]]; then
	log "setting zsh as the login shell"
	chsh -s /usr/bin/zsh || warn "chsh failed, run it yourself"
fi

log "creating directories"
mkdir -p "$HOME"/{devel,notes,pictures/screenshots,.local/state/amalthea,.local/share/tmux}
xdg-user-dirs-update 2>/dev/null

# the old layout had everything under dotfiles/amalthea/; those symlinks now
# dangle, and bin/link refuses to touch a path that already exists
log "clearing dangling symlinks from the previous layout"
find "$HOME" -maxdepth 1 -xtype l -print -delete 2>/dev/null
find "$HOME/.config" -maxdepth 1 -xtype l -print -delete 2>/dev/null

# bin/link refuses to touch a path that is a real file, which is right, but it
# means a leftover from the old setup silently wins. move those aside first.
conf_section() { sed -n "/^\\[$1\\]/,/^\\[/{/^\\[/d;/^$/d;/^[#;]/d;p}" "$root/link.conf"; }

while IFS='=' read -r _rel target; do
	[[ -z ${target:-} ]] && continue
	t="${target/#\~/$HOME}"
	if [[ -e $t && ! -L $t ]]; then
		log "moving existing $t to $t.bak"
		mv -f "$t" "$t.bak"
	fi
done < <(conf_section file_links)

while IFS='=' read -r _name target; do
	[[ -z ${target:-} ]] && continue
	t="${target/#\~/$HOME}"
	# only an empty dir: a populated one is the user's data, leave it alone
	[[ -d $t && ! -L $t ]] && rmdir "$t" 2>/dev/null
done < <(conf_section path_overrides)

log "linking configs"
"$root/bin/link"

# seed a wallpaper so the first login is not a grey X root window
if [[ ! -s "$HOME/.local/state/amalthea/wallpaper" ]]; then
	printf '%s\n' "$HOME/wallpapers/wallpaper.jpg" > "$HOME/.local/state/amalthea/wallpaper"
fi

log "monitor hotplug hook"
sudo install -Dm755 "$root/scripts/display-hotplug.sh" /usr/local/bin/amalthea-display-hotplug
sudo tee /etc/systemd/system/amalthea-display.service >/dev/null <<'EOF'
[Unit]
Description=reapply the amalthea display layout after a monitor hotplug
# xrandr can itself emit a drm change event, so without a rate limit this
# unit can retrigger itself in a loop
StartLimitIntervalSec=10
StartLimitBurst=2

[Service]
Type=oneshot
ExecStart=/usr/local/bin/amalthea-display-hotplug
# the hook restarts polybar, and those live in this unit's cgroup. the default
# KillMode takes the whole group down the moment ExecStart returns, which
# leaves the layout correct and no bar on it
KillMode=process
EOF
# udev kills anything slow started from RUN+=, so it only pokes the unit
sudo tee /etc/udev/rules.d/95-amalthea-display.rules >/dev/null <<'EOF'
ACTION=="change", SUBSYSTEM=="drm", RUN+="/bin/systemctl start --no-block amalthea-display.service"
EOF
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

log "rebuilding the font cache"
fc-cache -f >/dev/null 2>&1

cat <<'EOF'

done.

  one more step: $DOTFILES_DIR/scripts/vscode-patches.sh (marketplace access
  and the system font for vscodium - safe to re-run, --force reverts it)

  log out of this tty and log back in on tty1 - zprofile runs startx there.
  if X does not come up, the reason is in ~/.local/state/amalthea/startx.log

  alt+return   terminal        alt+space  launcher
  alt+w        close           alt+f      fullscreen
  alt+1..9     workspace       alt+esc    power menu
  alt+n        wifi            alt+b      bluetooth
  alt+v        clipboard       alt+e      emoji
  alt+p        projects        alt+k      us/cz layout
  alt+shift+n  tailnet         alt+shift+l  lock
  ctrl+shift+4 region shot     ctrl+shift+3 full shot

EOF
