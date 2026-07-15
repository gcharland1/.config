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
    if [ -z "$uuid" ]; then
        echo "no default gnome-terminal profile found, skipping"
        return
    fi
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

apply_tmux() {
    local file="$1"
    local content
    content="set -g status-style \"bg=$background fg=$foreground\"

set -g pane-border-style \"fg=$color8\"
set -g pane-active-border-style \"fg=$color6\"

set -g window-status-current-style \"fg=$color6 bg=$background\""
    replace_block "$file" "TMUX" "$content"
}

apply_foot() {
    local file="$1"
    local content
    content="background=${background#\#}
foreground=${foreground#\#}

regular0=${color0#\#}
regular1=${color1#\#}
regular2=${color2#\#}
regular3=${color3#\#}
regular4=${color4#\#}
regular5=${color5#\#}
regular6=${color6#\#}
regular7=${color7#\#}

bright0=${color8#\#}
bright1=${color9#\#}
bright2=${color10#\#}
bright3=${color11#\#}
bright4=${color12#\#}
bright5=${color13#\#}
bright6=${color14#\#}
bright7=${color15#\#}"
    replace_block "$file" "FOOT" "$content"
}

apply_dunst() {
    local file="$1"

    replace_block "$file" "GLOBAL" "    frame_color = \"$background\""

    replace_block "$file" "LOW" "    background = \"$background\"
    foreground = \"$foreground\""

    replace_block "$file" "NORMAL" "    background = \"$background\"
    foreground = \"$foreground\"
    frame_color = \"$accent\""

    replace_block "$file" "CRITICAL" "    background = \"$color1\"
    foreground = \"$foreground\"
    frame_color = \"$background\""
}

if command -v dconf >/dev/null 2>&1; then
    apply_gnome_terminal
else
    echo "dconf not found, skipping gnome-terminal"
fi
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"
apply_tmux "$CONFIG_DIR/tmux/tmux.conf"
apply_foot "$CONFIG_DIR/foot/foot.ini"
apply_dunst "$CONFIG_DIR/dunst/dunstrc"

echo "Palette applied."
