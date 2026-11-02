# amalthea - zsh
# same shape as the asahi zshrc so muscle memory carries; wayland tools and the
# sdks that are not on this machine are the only things dropped.

# defaults
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="firefox"
export TERMINAL="alacritty"
export DOTFILES_DIR="$HOME/dotfiles"

# locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# xdg
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# sdks
export GOPATH="$HOME/go"
export CARGO_HOME="$HOME/.cargo"

# path
typeset -U path
path=(
	"$HOME/dotfiles/bin"
	"$HOME/dotfiles/scripts"
	"$GOPATH/bin"
	"$HOME/.local/bin"
	"$HOME/.cargo/bin"
	$path
)

# Aliases ------------------------------------------------------------------------------------

alias dots='cd ~/dotfiles'

alias sr='source ~/.zshrc && echo "shell reloaded"'

alias lg='lazygit'
alias gs='git status -sb'
alias ga='git add'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias gb='gh browse'

alias copy='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'
alias path='echo $PATH | tr ":" "\n"'
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'

alias d='trash'
alias c='clear'
alias info='scc'
alias mem='ps_mem'

alias cd='z'
alias ls='echo && eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias lsa='echo && eza --color=always --long --git --icons=always'
alias lsaa='echo && eza --color=always --long --git --icons=always -a'
alias lst='echo && eza --color=always --tree --git --no-filesize --icons=always --no-time --no-user --no-permissions'

alias lip="ip -4 -br addr show scope global | awk '{print \$3}' | cut -d/ -f1 | head -1"

alias q='tmux detach'
alias qa='tmux kill-server'
alias tl='tmux display-message -p "#{window_layout}"'

alias n='clear && fastfetch'

alias cc='clear && claude --dangerously-skip-permissions'
alias ccc='clear && claude --dangerously-skip-permissions --continue'

# this machine specific
alias bar='~/dotfiles/config/polybar/launch.sh'
alias i3r='i3-msg restart'
alias hdd='cd /mnt/hdd'

# plugins ------------------------------------------------------------------------------------

eval "$(starship init zsh)"

source $HOME/.config/shell/zsh-highlighting.sh || echo "error: zsh-syntax-highlighting failed to source"
source $HOME/.config/shell/yazi.sh || echo "error: yazi failed to source"

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null \
	|| source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5a5f66,italic"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# bat: base16 reads the terminal's own 16 colours, so it tracks the alacritty
# palette instead of needing its own theme file
export BAT_THEME="base16"
export MANPAGER="sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"

# fzf
source <(fzf --zsh)
export FZF_CTRL_R_OPTS="--style minimal --color 16 --info inline --no-sort --no-preview"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="
  --color=fg:#8b9097,fg+:#ffffff,bg+:#16181b,hl:#6f94ac,hl+:#9fb0ba
  --color=info:#8b9097,prompt:#6f94ac,pointer:#6f94ac,marker:#9fb0ba,border:#3a3e44
  --color=header:#8b9097,spinner:#6f94ac
"

# completions ---------------------------------------------------------------------------------

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors "$LS_COLORS" ma=0\;35
zstyle ':completion:*' squeeze-slashes false

_rmt() {
	local -a hosts
	hosts=(${(f)"$(rmt --complete 2>/dev/null)"})
	_describe 'host' hosts
}
command -v rmt >/dev/null && compdef _rmt rmt

# shell options ------------------------------------------------------------------------------

setopt append_history inc_append_history share_history hist_ignore_dups hist_ignore_space
setopt autocd
setopt auto_param_slash
setopt no_case_glob no_case_match
setopt globdots
setopt extended_glob
setopt interactive_comments
unsetopt prompt_sp
stty stop undef
bindkey -e

# history ------------------------------------------------------------------------------------

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history"

# tmux separate history
if [[ -n $TMUX_PANE ]]; then
	HISTDIR="$HOME/.zsh_tmux_hist"
	mkdir -p "$HISTDIR"
	HISTFILE="$HISTDIR/.zsh_history_${TMUX_PANE:1}"
	if [[ ! -f $HISTFILE ]]; then
		cp "$XDG_CACHE_HOME/zsh_history" "$HISTFILE" 2>/dev/null
	fi
fi

# zoxide wants to be last
eval "$(zoxide init zsh)"

# LEAVE AT THE BOTTOM
if [[ "$TERM" == "alacritty" ]]; then
	tm
fi
