#!/bin/sh

spacer="${1:-150}"

# If ACPI was not installed, this probably is a battery-less computer.
DATE=$(date +" %d-%b  -  %H:%M")
BUFFER=$(printf '%*s' $spacer '')
echo "$DATE$BUFFER"

