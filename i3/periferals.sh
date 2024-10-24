#!/bin/bash

# Setup monitors according to the wifi connected
$HOME/.config/scripts/workspace/setupMonitors.sh

# Set internal microphone
pactl set-source-port alsa_input.pci-0000_00_1f.3.analog-stereo analog-input-internal-mic && \
    pactl set-source-volume alsa_input.pci-0000_00_1f.3.analog-stereo 0x4000
