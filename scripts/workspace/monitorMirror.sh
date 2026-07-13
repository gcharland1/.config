#!/bin/bash

if [ -n "$WAYLAND_DISPLAY" ]; then
    main=$(wlr-randr | grep -E '^eDP' | awk '{print $1}')
    external=$(wlr-randr | grep -E '^[A-Za-z]' | awk '{print $1}' | grep -v "^$main$")

    wlr-randr --output "$main" --pos 0,0
    wlr-randr --output "$external" --pos -1920,0
else
    xrandr --output $(xrandr --listmonitors | grep -vE "eDP|Monitors:" | awk '{print $4}') --same-as eDP-1
fi
