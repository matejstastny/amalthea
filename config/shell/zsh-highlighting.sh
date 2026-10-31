#!/bin/zsh

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
	|| source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_STYLES[command]='fg=#c4745a,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#c4745a,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#c4745a,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#c4745a,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c9a05e,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#96a06b'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#96a06b'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#a8928a'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#a8928a'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#4a3832,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#a85540,bold,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#f0e4de,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#c9a05e'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#a8928a'
