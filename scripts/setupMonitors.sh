!#/usr/bin/bash

xrandr --output HDMI1 --auto
xrandr --output DP1 --auto
xrandr --output DP2 --auto
xrandr --output HDMI1 --right-of eDP1 
xrandr --output DP1 --left-of eDP1
xrandr --output DP2 --left-of eDP1
