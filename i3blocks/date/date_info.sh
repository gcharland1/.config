#!/bin/sh

# If ACPI was not installed, this probably is a battery-less computer.
DATE=$(date +" %d-%b-%Y  -  %H:%M")
BUFFER=$(printf '%*s' 150 '')
echo "$DATE$BUFFER"

