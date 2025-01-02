# Pour trouver le nom de ton headset
#
# pacmd list-sources | grep 'name: '

source="alsa_input.pci-0000_00_1f.3.analog-stereo" # Le nom de ton headset ici
volume=0x4400 # C'est un pas pire point de départ

pacmd set-default-source $source
pacmd set-source-volume $source $volume
