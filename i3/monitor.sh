#!/usr/bin/sh

HDMI1_STATUS2=$(xrandr | grep "HDMI1")
DP2_STATUS2=$(xrandr | grep "DP2")

while :; do
    HDMI1_STATUS1=$(xrandr | grep "HDMI1")
    if [ "$HDMI1_STATUS1" != "$HDMI1_STATUS2" ]; then
        IS_CONNECTED=$(echo $HDMI1_STATUS1 | grep " connected" | wc -l)
        if [ $IS_CONNECTED -eq 1 ]; then
            xrandr --output HDMI1 --auto --mode 1920x1080 --left-of eDP1
        else
            xrandr --output HDMI1 --auto
        fi
    fi
    HDMI1_STATUS2=$HDMI1_STATUS1

    DP2_STATUS1=$(xrandr | grep "DP2")
    if [ "$DP2_STATUS1" != "$DP2_STATUS2" ]; then
        IS_CONNECTED=$(echo $DP2_STATUS1 | grep " connected" | wc -l)
        if [ $IS_CONNECTED -eq 1 ]; then
            xrandr --output DP2 --auto --mode 1920x1080 --left-of eDP1
        else
            xrandr --output DP2 --auto
        fi
    fi
    DP2_STATUS2=$DP2_STATUS1    
    sleep 5
done
