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
	i3-wm picom polybar rofi dunst i3lock xss-lock feh numlockx
	maim slop xclip xdotool wmctrl imagemagick clipmenu rofimoji
	papirus-icon-theme gnome-themes-extra adwaita-icon-theme

	# fonts
	ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-nerd-fonts-symbols-mono
	noto-fonts noto-fonts-emoji

	# terminal + shell
	alacritty tmux zsh zsh-autosuggestions zsh-syntax-highlighting
	starship zoxide eza fzf ripgrep fd bat btop yazi lazygit
	neovim git github-cli jq trash-cli fastfetch man-db man-pages
	wget curl unzip p7zip rsync openssh less tree

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
	firefox zathura zathura-pdf-mupdf mpv
)

log "syncing and upgrading"
sudo pacman -Syu --noconfirm --needed || { err "pacman -Syu failed"; exit 1; }

log "installing ${#pkgs[@]} packages"
sudo pacman -S --noconfirm --needed "${pkgs[@]}" || warn "some packages failed, see above"

# things that only live in the aur. all optional - the shell aliases that use
# them degrade to "command not found" and nothing else breaks
aur=(ps_mem scc gitmux)
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
mkdir -p "$HOME"/{devel,notes,wallpapers,pictures/screenshots,.local/state/amalthea,.local/share/tmux}
xdg-user-dirs-update 2>/dev/null

# the old layout had everything under dotfiles/amalthea/; those symlinks now
# dangle, and bin/link refuses to touch a path that already exists
log "clearing dangling symlinks from the previous layout"
find "$HOME" -maxdepth 1 -xtype l -print -delete 2>/dev/null
find "$HOME/.config" -maxdepth 1 -xtype l -print -delete 2>/dev/null

log "linking configs"
"$root/bin/link"

# seed a wallpaper so the first login is not a grey X root window
if [[ ! -s "$HOME/.local/state/amalthea/wallpaper" ]]; then
	printf '%s\n' "$HOME/wallpapers/amalthea-ember.png" > "$HOME/.local/state/amalthea/wallpaper"
fi

log "rebuilding the font cache"
fc-cache -f >/dev/null 2>&1

cat <<'EOF'

done.

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
