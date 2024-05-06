# Setup tous les moniteurs par défaut (Reset)
xrandr --output DP1 --auto
xrandr --output DP2 --auto
xrandr --output HDMI1 --auto
xrandr --output HDMI2 --auto

xrandr --output DP1 --left-of eDP1
xrandr --output DP2 --left-of eDP1
xrandr --output HDMI1 --right-of eDP1
