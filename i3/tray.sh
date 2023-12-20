#!/bin/bash

pkill -f blueman-applet
pkill -f nm-applet
pkill -f pasystray

blueman-applet &
nm-applet &
sleep 1
pasystray &
