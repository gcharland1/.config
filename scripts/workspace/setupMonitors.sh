#!/usr/bin/bash

WIFI=$(iwgetid -r)

POSITION_HOME="--left-of"
POSITION_WORK="--left-of"
[[ $WIFI == Le\ Flash* ]] && position=$POSITION_HOME || position=$POSITION_WORK

if [ -n "$WAYLAND_DISPLAY" ]; then
    main=$(wlr-randr | grep -E '^eDP' | awk '{print $1}')
    monitors=$(wlr-randr | grep -E '^[A-Za-z]' | awk '{print $1}' | grep -v "^$main$")

    wlr-randr --output "$main" --mode 1920x1200 --pos 0,0
    for m in $monitors; do
        wlr-randr --output "$m" --mode 1920x1080 --pos -1920,0
    done
else
    # Setup tous les moniteurs par défaut (Reset)
    for m in $(xrandr -q | grep '^[DP|HDMI]' | awk '{print $1}'); do
        xrandr --output $m --auto
    done

    monitors=$(xrandr --listmonitors | grep -v 'Monitors:' | awk '{print $4}' | grep -v 'e')
    main=$(xrandr --listmonitors | grep -v 'Monitors:' | awk '{print $4}' | grep 'e')

    xrandr --output $main --primary --mode 1920x1200
    for m in $monitors; do
        xrandr --output $m $position $main --primary --mode 1920x1080
    done
fi
