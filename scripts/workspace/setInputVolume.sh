# Pour trouver le nom de ton headset
#
# pactl list sources short | grep 'my-headset-keyword'

microphone=$(pactl list sources short | grep Antlion | awk '{print $2}') # Check pour voir si mon mic est branché
volume="100%" # Mon micro peut prendre le volume à 100%

# Si on trouve pas le micro
if [ -z $microphone ]; then
    microphone="alsa_input.pci-0000_00_1f.3.analog-stereo" # Le micro de l'ordi
    volume="38%" # Input volume pour le micro d'ordi
fi

# Set pulse-audio
pactl set-default-source $microphone
pactl set-source-volume $microphone $volume

# Notif l'user
notify-send "Mic. Config:" "$microphone @ $volume"
