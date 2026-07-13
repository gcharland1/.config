#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/palette.sh"

# replace_block FILE MARKER CONTENT
# Replaces everything strictly between "# BEGIN_PALETTE_<MARKER>" and
# "# END_PALETTE_<MARKER>" (both marker lines are kept) with CONTENT.
# Idempotent: safe to call repeatedly.
replace_block() {
    local file="$1" marker="$2" content="$3"
    local begin="# BEGIN_PALETTE_${marker}"
    local end="# END_PALETTE_${marker}"
    awk -v begin="$begin" -v end="$end" -v content="$content" '
        index($0, begin) { print; print content; skip=1; next }
        index($0, end) { skip=0 }
        skip { next }
        { print }
    ' "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
}

apply_gnome_terminal() {
    local uuid
    uuid=$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")
    local base="/org/gnome/terminal/legacy/profiles:/:$uuid"

    dconf write "$base/background-color" "'$background'"
    dconf write "$base/foreground-color" "'$foreground'"
    dconf write "$base/palette" "['$color0', '$color1', '$color2', '$color3', '$color4', '$color5', '$color6', '$color7', '$color8', '$color9', '$color10', '$color11', '$color12', '$color13', '$color14', '$color15']"
}

apply_i3_like() {
    local file="$1"
    local content
    content="set \$black      $background
set \$main       $accent
set \$red        $color1
set \$white      $foreground
set \$yellow     $color3
set \$blue       $color4"
    replace_block "$file" "I3" "$content"
}

apply_gnome_terminal
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"

echo "Palette applied."
