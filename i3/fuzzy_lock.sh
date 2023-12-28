#!/bin/bash

# Take screenshot of the entire screen and blur it out
import -window root /tmp/fuzzylock.png
convert /tmp/fuzzylock.png -resize 25% /tmp/fuzzylock.png
convert /tmp/fuzzylock.png -resize 400% /tmp/fuzzylock.png

# Use i3Lock to lock the screen with the screenshot as a background
i3lock -i /tmp/fuzzylock.png
