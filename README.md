# amalthea

ThinkPad SL510, Arch, i3 on X11.

A 2009 machine: Core 2 Duo T5870, 5.6 GB RAM, Intel GM45 graphics, 1366x768.
The hardware picks most of the stack here. GM45 exposes **OpenGL 2.1 / GLES 2.0**
and nothing above it, which rules out Hyprland, kitty, ghostty and Quickshell -
all of them want GL 3.3. So this branch is X11, and the choices below follow from
that rather than from the asahi branch.

What does carry over is the workflow: **the binds are the same**. Mod is Alt,
`alt+return` is a terminal, `alt+space` is the launcher, `alt+w` closes,
`alt+1..9` are workspaces. Every Quickshell menu on asahi has a rofi script here
under the same key.

## stack

| job            | asahi      | here       | why |
| -------------- | ---------- | ---------- | --- |
| compositor     | Hyprland   | i3         | no GL 3.3; i3 needs none |
| bar            | Quickshell | polybar    | X11-native, no GTK, no QML engine |
| launcher       | Quickshell | rofi       | same shape: type, enter |
| notifications  | Quickshell | dunst      | |
| terminal       | kitty      | alacritty  | kitty needs GL 3.3, alacritty runs on GLES 2 |
| compositing    | built in   | picom      | `xrender` backend; glx needs GL 3.0 |
| screenshots    | grim/slurp | maim/slop  | |
| clipboard      | wl-clipboard | xclip    | |
| lock           | Quickshell | i3lock + xss-lock | |
| editor         | neovim     | neovim     | same config, ember palette |
| multiplexer    | tmux       | tmux       | same config |

## theme

`amalthea ember`. Amalthea is the reddest object in the solar system, so the
ramp is warm where the asahi one is cool: `#16100f` near-black, terracotta
`#c4745a` as the accent, ochre `#c9a05e` as the second. Font is Iosevka
(IosevkaTerm for the monospace slot - it holds a strict cell at 10pt, which
matters on a 768px panel).

`config/amalthea/palette.sh` is the source of truth; every script sources it.

## displays

The HDMI port drives an external monitor as a second head. One hard limit worth
knowing: **GM45's HDMI is capped at a 165 MHz TMDS clock**, which is 1920x1080
at 60 Hz and no more. A 4K panel negotiates down to 1080p and the kernel does
not even list the 4K modes - 3840x2160 at 60 needs 594 MHz, which is HDMI 2.0,
six years younger than this chipset. On a 4K panel 1080p is at least an exact
2:1 integer scale, so it stays sharp rather than going soft.

`extend` stacks the laptop *under* the external rather than beside it. That is
deliberate: gen4 chips lose their tiled framebuffer once the screen gets wider
than the fence stride allows, which drops SNA back to an untiled buffer and
makes every 2D operation crawl. Stacking keeps the screen as wide as the
external alone instead of as wide as both combined. `display.sh side` is there
if you want them side by side anyway.

| key | does |
| --- | --- |
| `alt+d` | layout menu |
| `display.sh auto` | extend if an external is attached, else laptop only |
| `display.sh status` | what is connected and at what mode |

A udev rule re-runs `display.sh auto` whenever a connector changes, so plugging
the monitor in extends onto it and unplugging folds back to the panel instead
of stranding windows on a dead output.

## disks

Root lives on the Kingston SSD. The 250 GB Seagate is mounted at `/mnt/hdd` and
still carries a bootable Arch root as a fallback - both disks have GRUB in their
MBR, so either one boots.

## install

```sh
git clone https://github.com/matejstastny/dotfiles.git ~/dotfiles
cd ~/dotfiles && git checkout arch
./install.sh
```

Idempotent. Log out and back in on tty1; `.zprofile` runs `startx` there and
nowhere else. If X does not come up the reason is in
`~/.local/state/amalthea/startx.log`.

`bin/link` symlinks `config/*` into `~/.config` (see `link.conf` for the
exceptions). It never overwrites a real file.

## binds

| key | does |
| --- | --- |
| `alt+return` | terminal |
| `alt+space` | launcher |
| `alt+w` / `alt+f` | close / fullscreen |
| `alt+1..9` | workspace, `+shift` to move the window |
| `alt+←↓↑→` | focus, `+shift` to move |
| `alt+tab` / `alt+\`` | workspace to other output / back and forth |
| `ctrl+tab` | cycle siblings (the hy3 tab bind) |
| `alt+s` / `alt+t` | split / tabbed layout |
| `alt+n` / `alt+b` | wifi / bluetooth |
| `alt+v` / `alt+e` | clipboard history / emoji |
| `alt+p` / `alt+shift+n` | projects / tailnet |
| `alt+k` | toggle us ↔ cz |
| `alt+c` | dismiss notifications |
| `alt+esc` | power menu |
| `alt+shift+l` | lock |
| `alt+shift+c` | pick a colour |
| `alt+shift+o` / `alt+shift+w` | open / close the app set |
| `alt+shift+r` | restart i3 |
| `ctrl+shift+4` / `ctrl+shift+3` | region / full screenshot |

## notes

- picom costs real CPU on this chip. `pkill picom` if you want the frames back;
  nothing depends on it.
- mpv is set up for VA-API, so h264 decodes on the GPU. Anything above 720p is
  optimistic.
- Firefox runs software WebRender (`MOZ_WEBRENDER=0` in `.xinitrc`) because GL
  2.1 cannot drive the hardware path.
- **Bun will not run on this CPU at all.** A Core 2 Duo has no SSE4.2 and bun
  needs it even in the baseline build. Node is fine. Anything else shipping
  prebuilt x86-64-v2 binaries will die with SIGILL for the same reason.
- `.xinitrc` exports `LANG` because `.zprofile` runs `startx` before `.zshrc`
  gets a chance to. Without it every X client that is not a child of a login
  shell comes up in the C locale and btop refuses to start.
