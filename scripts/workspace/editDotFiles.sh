#!/bin/bash

dotFilesPath="$HOME/.config"
declare -a options=(
    "i3wm - i3/config"
    "aliases - my_aliases"
    "scripts - scripts/workspace/"
    "vim - nvim"
    "zsh - oh-my-zsh/"
)

conf=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'Select config file:' -l 20 | awk '{print $NF}')
[ ! -z "$conf" ] \
    && x-terminal-emulator -e vim "$HOME/.config/$conf" \
    || exit
