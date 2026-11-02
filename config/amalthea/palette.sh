#!/usr/bin/env bash
#@ amalthea steel - single source of truth for the palette
# a cold ramp for a black 2009 ThinkPad: true near-black neutrals, a steel
# blue as the primary accent, a paler ice-blue as the second.
# sourced by every script that needs to draw something.

# neutrals, darkest to lightest
export AM_BASE="#0a0a0b"
export AM_MANTLE="#0f1012"
export AM_SURFACE="#16181b"
export AM_OVERLAY="#202327"
export AM_MUTED="#3a3e44"
export AM_SUBTLE="#5a5f66"
export AM_DIM="#8b9097"
export AM_TEXT="#e4e6e9"
export AM_BRIGHT="#ffffff"

# accents
export AM_EMBER="#6f94ac"  # primary
export AM_AMBER="#9fb0ba"  # secondary
export AM_RUST="#b3555a"   # urgent
export AM_SAGE="#7a9a84"   # ok
export AM_SLATE="#5f7e91"  # info
export AM_PLUM="#8a7a95"
export AM_TEAL="#6f9690"

# hex without the leading # - i3lock, maim and friends want it bare
export AM_BASE_RAW="0a0a0b"
export AM_EMBER_RAW="6f94ac"
export AM_TEXT_RAW="e4e6e9"
export AM_RUST_RAW="b3555a"

export AM_FONT="Terminess Nerd Font Mono"
export AM_FONT_TERM="Terminess Nerd Font Mono"
