#!/bin/bash

if [ -n "$WAYLAND_DISPLAY" ]; then
    swaylock --color 141414
else
    if (( $RANDOM % 3 )); then
        i3lock --nofork --color 141414
    else
        # Take screenshot of the entire screen and blur it out
        import -window root /tmp/fuzzylock.png
        convert /tmp/fuzzylock.png -resize 16% /tmp/fuzzylock.png
        convert /tmp/fuzzylock.png -resize 625% /tmp/fuzzylock.png

        # Use i3Lock to lock the screen with the screenshot as a background
        i3lock -i /tmp/fuzzylock.png
    fi
fi
