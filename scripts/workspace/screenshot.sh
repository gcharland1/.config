#!/bin/bash

mode="${1:-full}"

if [ -n "$WAYLAND_DISPLAY" ]; then
    case "$mode" in
        full)
            grim - | wl-copy
            ;;
        gui)
            grim -g "$(slurp)" - | wl-copy
            ;;
    esac
else
    case "$mode" in
        full)
            gnome-screenshot -acf /tmp/screenshot && cat /tmp/screenshot | xclip -i -selection clipboard -target image/png
            ;;
        gui)
            flameshot gui
            ;;
    esac
fi
