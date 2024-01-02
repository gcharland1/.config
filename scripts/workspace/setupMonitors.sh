# Setup tous les moniteurs par défaut (Reset)
xrandr --output DP-1 --auto
xrandr --output DP-2 --auto
xrandr --output HDMI-1 --auto
xrandr --output HDMI-1 --auto

xrandr --output DP-1 --left-of eDP-1
xrandr --output DP-2 --left-of eDP-1
xrandr --output HDMI-1 --right-of eDP-1
