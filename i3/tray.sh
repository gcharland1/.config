#!/bin/bash

pkill -f blueman-applet
pkill -f nm-applet
pkill -f systray

nm-applet &
blueman-applet &
sleep 1
pasystray --volume-inc=1 --no-notify &
