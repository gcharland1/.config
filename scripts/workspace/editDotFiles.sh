#!/bin/bash

dotFilesPath="$HOME/.config"
declare -a options=(
    "i3wm - i3/config"
    "scripts - scripts/workspace"
    "vim - nvim"
)

conf=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'Select config file:' -l 20 | awk '{print $NF}')
[ ! -z "$conf" ] \
    && x-terminal-emulator -e nvim "$HOME/.config/$conf" \
    || exit
