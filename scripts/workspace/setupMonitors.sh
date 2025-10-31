#!/usr/bin/bash

# Setup tous les moniteurs par défaut (Reset)
for m in $(xrandr -q | grep '^[eDP|DP|HDMI]' | awk '{print $1}'); do
    xrandr --output $m --auto
done

WIFI=$(iwgetid -r)

POSITION_HOME="--left-of"
POSITION_WORK="--left-of"
[[ $WIFI == Le\ Flash* ]] && position=$POSITION_HOME || position=$POSITION_WORK

# TODO: Remplacer xrandr par wlr-randr
monitors=$(xrandr --listmonitors | grep -v 'Monitors:' | awk '{print $4}' | grep -v 'e')
main=$(xrandr --listmonitors | grep -v 'Monitors:' | awk '{print $4}' | grep 'e')

xrandr --output $main --primary --mode 1920x1200
for m in $monitors; do
    xrandr --output $m $position $main --primary
done
