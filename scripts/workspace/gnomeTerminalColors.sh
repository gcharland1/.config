#!/bin/bash

PROFILE_ID="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"


black="#131313"
white="#b2b2b2"
darkGrey="#3a3a3a"
lightGrey="#e4e4e4"
grey="#5f5f5f"

red="#a75f5f"
green="#5f875f"
yellow="#a7873f"
blue="#5f5fa7"
purple="#875f87"
cyan="#5f8787"

gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ background-color $black
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ foreground-color $white
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ cursor-background-color $white
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ cursor-foreground-color $darkGrey
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ palette "['$black', '$red', '$green', '$yellow', '$blue', '$purple', '$cyan', '$white', '$grey', '$red', '$green', '$yellow', '$blue', '$purple', '$cyan', '$lightGrey']"

