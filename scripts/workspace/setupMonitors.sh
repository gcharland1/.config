# Setup tous les moniteurs par défaut (Reset)
for m in $(xrandr -q | grep '^[eDP|DP|HDMI]' | awk '{print $1}'); do
    xrandr --output $m --auto
done

WIFI=$(iwgetid -r)
[ "$WIFI" = "Le Flash" ] && position="--right-of" || position="--left-of"

monitors=$(xrandr --listmonitors | grep -v 'Monitors:' | awk '{print $4}' | grep -v 'e')
main=$(xrandr --listmonitors | grep -v 'Monitors:' | awk '{print $4}' | grep 'e')

xrandr --output $main --primary
for m in $monitors; do
    xrandr --output $m $position $main --primary
done
