#!/usr/bin/env bash
#@ polybar: active window's app name - same formatting as the asahi quickshell
# bar's BarActiveWindow.qml: take the class, keep only what's after the last
# dot, lowercase it

class=$(xdotool getactivewindow getwindowclassname 2>/dev/null)
[[ -z $class ]] && exit 0
name="${class##*.}"
echo "${name,,}"
