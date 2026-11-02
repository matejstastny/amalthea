#!/bin/zsh

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null \
	|| source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_STYLES[command]='fg=#6f94ac,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#6f94ac,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#6f94ac,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#6f94ac,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=#9fb0ba,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#7a9a84'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#7a9a84'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#8b9097'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#8b9097'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#3a3e44,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#b3555a,bold,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#e4e6e9,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#9fb0ba'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#8b9097'
