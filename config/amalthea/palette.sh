#!/usr/bin/env bash
#@ amalthea ember - single source of truth for the palette
# amalthea is the reddest object in the solar system, so the ramp is warm:
# a near-black with red in it, terracotta as the accent, ochre as the second.
# sourced by every script that needs to draw something.

# neutrals, darkest to lightest
export AM_BASE="#16100f"
export AM_MANTLE="#1b1413"
export AM_SURFACE="#241a18"
export AM_OVERLAY="#30231f"
export AM_MUTED="#4a3832"
export AM_SUBTLE="#6b524a"
export AM_DIM="#a8928a"
export AM_TEXT="#f0e4de"
export AM_BRIGHT="#fff8f4"

# accents
export AM_EMBER="#c4745a"  # primary
export AM_AMBER="#c9a05e"  # secondary
export AM_RUST="#a85540"   # urgent
export AM_SAGE="#96a06b"   # ok
export AM_SLATE="#7a8fa6"  # info
export AM_PLUM="#b07a8a"
export AM_TEAL="#85a69b"

# hex without the leading # - i3lock, maim and friends want it bare
export AM_BASE_RAW="16100f"
export AM_EMBER_RAW="c4745a"
export AM_TEXT_RAW="f0e4de"
export AM_RUST_RAW="a85540"

export AM_FONT="Iosevka Nerd Font"
export AM_FONT_TERM="IosevkaTerm Nerd Font"
