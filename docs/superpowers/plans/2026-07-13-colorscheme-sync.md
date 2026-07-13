# Colorscheme Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make one canonical 16-color palette (gnome-terminal's current profile) the single source of truth, propagated to i3, sway, tmux, and dunst by a generator script.

**Architecture:** A plain-bash data file (`scripts/colorscheme/palette.sh`) defines the palette. A generator script (`scripts/colorscheme/apply.sh`) sources it and rewrites each target: marker-delimited blocks in `i3/config`/`sway/config`/`tmux/tmux.conf`/`dunst/dunstrc`, and a live `dconf write` for gnome-terminal (profile UUID looked up at runtime, never hardcoded). Re-running `apply.sh` is always safe (idempotent) — it fully replaces the content between markers each time.

**Tech Stack:** bash, awk, dconf (GSettings), i3/sway config format, tmux config format, dunstrc (INI-like) format.

## Global Constraints

- Canonical palette values (from gnome-terminal's live profile, verified against `dconf read`):
  `background=#0a0a0a`, `foreground=#b2b2b2`,
  `color0=#0a0a0a` `color1=#a75f5f` `color2=#5f875f` `color3=#a7873f` `color4=#5f5fa7` `color5=#875f87` `color6=#5f8787` `color7=#b2b2b2`,
  `color8=#5f5f5f` `color9=#a75f5f` `color10=#5f875f` `color11=#a7873f` `color12=#5f5fa7` `color13=#875f87` `color14=#5f8787` `color15=#e4e4e4`,
  `accent=#406464` (i3 border/dunst-normal-frame teal — not an ANSI slot).
- Marker convention: `# BEGIN_PALETTE_<NAME>` / `# END_PALETTE_<NAME>` (both lines preserved, content between them fully replaced on each run) — mirrors the existing `# BEGIN_KITTY_THEME`/`# END_KITTY_THEME` convention in `kitty/kitty.conf`.
- `apply.sh` must be idempotent: running it twice in a row produces byte-identical output the second time.
- i3's `$background` variable (`#000000`, used only by `exec_always xsetroot -solid '$background'`) is explicitly out of scope — not part of any marked block, not touched.
- kitty and byobu are explicitly out of scope — do not touch `kitty/` or `byobu/` files.
- Both i3/config and sway/config define `$blue` (canonical `color4`, `#5f5fa7`) and use it for the launcher's `--tf`/`--hf`. i3/config currently uses `$main` there instead (a manual edit) — sync restores `$blue` there too, so both files match sway's current state exactly.
- All file paths below are relative to `/home/gcharland/.config`.
- zsh needs no task: the active oh-my-zsh theme (`eastwood`) uses named ANSI-color macros (`$fg[red]`, `$fg[cyan]`, etc.) that already resolve through gnome-terminal's palette at render time, so it's automatically in sync once Task 1 lands. Nothing to write for it.

---

### Task 1: Palette source file + gnome-terminal writer

**Files:**
- Create: `scripts/colorscheme/palette.sh`
- Create: `scripts/colorscheme/apply.sh`

**Interfaces:**
- Produces: `palette.sh` exports shell variables `background`, `foreground`, `color0`..`color15`, `accent` — every later task sources this file and reads these exact names.
- Produces: `apply.sh` defines a `replace_block(file, marker, content)` bash function — later tasks call it once per marked region. Signature: `replace_block "$file" "MARKER_NAME" "$content"` where `content` is the literal multi-line replacement text (no markers included in `content` — the function keeps the existing marker lines and swaps only what's between them). It rewrites `file` in place via a temp file + `mv`.
- Produces: `apply.sh` defines `apply_gnome_terminal()` (no args) which reads the live default profile UUID and writes `background-color`, `foreground-color`, and `palette` via `dconf write`.

- [ ] **Step 1: Create the palette directory and source file**

```bash
mkdir -p /home/gcharland/.config/scripts/colorscheme
```

Write `/home/gcharland/.config/scripts/colorscheme/palette.sh`:

```bash
#!/bin/bash
# Canonical color palette — single source of truth for i3, sway,
# gnome-terminal, tmux, and dunst.
#
# Edit values here, then run scripts/colorscheme/apply.sh to propagate.

background="#0a0a0a"
foreground="#b2b2b2"

color0="#0a0a0a";  color8="#5f5f5f"
color1="#a75f5f";  color9="#a75f5f"
color2="#5f875f";  color10="#5f875f"
color3="#a7873f";  color11="#a7873f"
color4="#5f5fa7";  color12="#5f5fa7"
color5="#875f87";  color13="#875f87"
color6="#5f8787";  color14="#5f8787"
color7="#b2b2b2";  color15="#e4e4e4"

accent="#406464"
```

- [ ] **Step 2: Verify the palette file is valid and has the right values**

Run:

```bash
bash -n /home/gcharland/.config/scripts/colorscheme/palette.sh && echo "syntax OK"
source /home/gcharland/.config/scripts/colorscheme/palette.sh
[ "$color4" = "#5f5fa7" ] && [ "$accent" = "#406464" ] && [ "$foreground" = "#b2b2b2" ] && echo "values OK"
```

Expected output:
```
syntax OK
values OK
```

- [ ] **Step 3: Create apply.sh with the replace_block helper and the gnome-terminal writer**

Write `/home/gcharland/.config/scripts/colorscheme/apply.sh`:

```bash
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

apply_gnome_terminal

echo "Palette applied."
```

```bash
chmod +x /home/gcharland/.config/scripts/colorscheme/apply.sh
```

- [ ] **Step 4: Run it and verify gnome-terminal's live profile matches the palette**

Run:

```bash
/home/gcharland/.config/scripts/colorscheme/apply.sh
uuid=$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")
dconf read "/org/gnome/terminal/legacy/profiles:/:$uuid/background-color"
dconf read "/org/gnome/terminal/legacy/profiles:/:$uuid/foreground-color"
dconf read "/org/gnome/terminal/legacy/profiles:/:$uuid/palette"
```

Expected output:
```
Palette applied.
'#0a0a0a'
'#b2b2b2'
['#0a0a0a', '#a75f5f', '#5f875f', '#a7873f', '#5f5fa7', '#875f87', '#5f8787', '#b2b2b2', '#5f5f5f', '#a75f5f', '#5f875f', '#a7873f', '#5f5fa7', '#875f87', '#5f8787', '#e4e4e4']
```

- [ ] **Step 5: Commit**

```bash
cd /home/gcharland/.config
git add scripts/colorscheme/palette.sh scripts/colorscheme/apply.sh
git commit -m "$(cat <<'EOF'
Add canonical color palette and gnome-terminal sync

scripts/colorscheme/palette.sh is now the single source of truth for
the 16-color ANSI palette (taken from gnome-terminal's existing
profile). apply.sh propagates it to gnome-terminal via dconf; later
commits extend it to i3/sway, tmux, and dunst.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: i3/sway sync

**Files:**
- Modify: `i3/config:36-43` (color variable block) and `i3/config:164-165` (bemenu bindings, `$main` → `$blue`)
- Modify: `sway/config:36-43` (color variable block)
- Modify: `scripts/colorscheme/apply.sh` (add `apply_i3_like`)

**Interfaces:**
- Consumes: `replace_block` from Task 1.
- Produces: `apply_i3_like(file)` — takes one arg (path to an i3-syntax config file), regenerates its `I3` marked block. Later tasks don't depend on this function.

- [ ] **Step 1: Wrap i3/config's color block in markers, and restore $blue**

In `i3/config`, replace:

```
# Set color variables
set $background #000000
set $black      #131313
set $main       #406464
set $red        #a75f5f
set $white      #dfdfdf
set $yellow     #a7a75f
```

with:

```
# Set color variables
set $background #000000
# BEGIN_PALETTE_I3
set $black      #131313
set $main       #406464
set $red        #a75f5f
set $white      #dfdfdf
set $yellow     #a7a75f
set $blue       #5f5fa7
# END_PALETTE_I3
```

Then restore the launcher's blue text (it currently uses `$main` here after an earlier manual edit; sway/config already uses `$blue`). Replace:

```
bindsym $mod+m exec j4-dmenu-desktop --dmenu="bemenu -i -p Launch: --nb '$black' --nf '$white' --tb '$black' --tf '$main' --hb '$black' --hf '$main' --sb '$white' --sf '$black' --fn 'Ubuntu Bold 12'"
bindsym $mod+Ctrl+m exec "bemenu-run -i -l 10 -p 'Run command:' --nb '$black' --nf '$white' --tb '$black' --tf '$main' --hb '$black' --hf '$main' --sb '$white' --sf '$black' --fn 'Ubuntu Bold 12'"
```

with:

```
bindsym $mod+m exec j4-dmenu-desktop --dmenu="bemenu -i -p Launch: --nb '$black' --nf '$white' --tb '$black' --tf '$blue' --hb '$black' --hf '$blue' --sb '$white' --sf '$black' --fn 'Ubuntu Bold 12'"
bindsym $mod+Ctrl+m exec "bemenu-run -i -l 10 -p 'Run command:' --nb '$black' --nf '$white' --tb '$black' --tf '$blue' --hb '$black' --hf '$blue' --sb '$white' --sf '$black' --fn 'Ubuntu Bold 12'"
```

(This now matches sway/config's existing bindings exactly.)

- [ ] **Step 2: Wrap sway/config's color block the same way (no other changes needed — its bindings already use $blue)**

In `sway/config`, replace:

```
# Set color variables
set $background #000000
set $black      #131313
set $main       #406464
set $red        #a75f5f
set $white      #dfdfdf
set $yellow     #a7a75f
set $blue       #5f5fa7
```

with:

```
# Set color variables
set $background #000000
# BEGIN_PALETTE_I3
set $black      #131313
set $main       #406464
set $red        #a75f5f
set $white      #dfdfdf
set $yellow     #a7a75f
set $blue       #5f5fa7
# END_PALETTE_I3
```

- [ ] **Step 3: Verify i3/config still parses**

Run:

```bash
i3-msg -t command "reload" 2>&1
```

Expected output: `[{"success":true}]`

(sway/config can't be syntax-checked without a running sway session; visual review is sufficient since the edit only added marker comments.)

- [ ] **Step 4: Add apply_i3_like to apply.sh**

In `scripts/colorscheme/apply.sh`, add this function after `apply_gnome_terminal` and before the `apply_gnome_terminal` call line:

```bash
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
```

Then change the bottom of the file from:

```bash
apply_gnome_terminal

echo "Palette applied."
```

to:

```bash
apply_gnome_terminal
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"

echo "Palette applied."
```

- [ ] **Step 5: Run it and verify both files now have identical, canonical color blocks**

Run:

```bash
/home/gcharland/.config/scripts/colorscheme/apply.sh
sed -n '/# BEGIN_PALETTE_I3/,/# END_PALETTE_I3/p' /home/gcharland/.config/i3/config
diff <(sed -n '/# BEGIN_PALETTE_I3/,/# END_PALETTE_I3/p' /home/gcharland/.config/i3/config) \
     <(sed -n '/# BEGIN_PALETTE_I3/,/# END_PALETTE_I3/p' /home/gcharland/.config/sway/config) \
  && echo "i3 and sway color blocks match"
i3-msg -t command "reload" 2>&1
```

Expected output:
```
# BEGIN_PALETTE_I3
set $black      #0a0a0a
set $main       #406464
set $red        #a75f5f
set $white      #b2b2b2
set $yellow     #a7873f
set $blue       #5f5fa7
# END_PALETTE_I3
i3 and sway color blocks match
[{"success":true}]
```

- [ ] **Step 6: Commit**

```bash
cd /home/gcharland/.config
git add i3/config sway/config scripts/colorscheme/apply.sh
git commit -m "$(cat <<'EOF'
Sync i3/sway colors to the canonical palette

$black and $white now match gnome-terminal's background/foreground
exactly instead of a close-but-different shade; $yellow corrects to
the terminal's actual yellow. Also restores i3's $blue (dropped in an
earlier manual edit in favor of $main) so both configs use the same
blue for the launcher's prompt/highlight text.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: tmux sync

**Files:**
- Modify: `tmux/tmux.conf:21-28`
- Modify: `scripts/colorscheme/apply.sh` (add `apply_tmux`)

**Interfaces:**
- Consumes: `replace_block` from Task 1.
- Produces: `apply_tmux(file)` — takes one arg (path to tmux.conf), regenerates its `TMUX` marked block.

- [ ] **Step 1: Wrap the relevant tmux.conf lines in markers**

In `tmux/tmux.conf`, replace:

```
# Color palette
set -g status-position bottom
set -g status-style "bg=colour16 fg=colour7"

set -g pane-border-style "fg=colour8"
set -g pane-active-border-style "fg=colour6"

set -g window-status-current-style "fg=colour6 bg=colour16"
```

with:

```
# Color palette
set -g status-position bottom
# BEGIN_PALETTE_TMUX
set -g status-style "bg=colour16 fg=colour7"

set -g pane-border-style "fg=colour8"
set -g pane-active-border-style "fg=colour6"

set -g window-status-current-style "fg=colour6 bg=colour16"
# END_PALETTE_TMUX
```

- [ ] **Step 2: Add apply_tmux to apply.sh**

In `scripts/colorscheme/apply.sh`, add this function after `apply_i3_like`:

```bash
apply_tmux() {
    local file="$1"
    local content
    content="set -g status-style \"bg=$background fg=$foreground\"

set -g pane-border-style \"fg=$color8\"
set -g pane-active-border-style \"fg=$color6\"

set -g window-status-current-style \"fg=$color6 bg=$background\""
    replace_block "$file" "TMUX" "$content"
}
```

Then change the bottom of the file from:

```bash
apply_gnome_terminal
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"

echo "Palette applied."
```

to:

```bash
apply_gnome_terminal
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"
apply_tmux "$CONFIG_DIR/tmux/tmux.conf"

echo "Palette applied."
```

- [ ] **Step 3: Run it and verify the raw ANSI-256 indices are gone**

Run:

```bash
/home/gcharland/.config/scripts/colorscheme/apply.sh
sed -n '/# BEGIN_PALETTE_TMUX/,/# END_PALETTE_TMUX/p' /home/gcharland/.config/tmux/tmux.conf
grep -c colour16 /home/gcharland/.config/tmux/tmux.conf || echo "no colour16 references left"
```

Expected output:
```
# BEGIN_PALETTE_TMUX
set -g status-style "bg=#0a0a0a fg=#b2b2b2"

set -g pane-border-style "fg=#5f5f5f"
set -g pane-active-border-style "fg=#5f8787"

set -g window-status-current-style "fg=#5f8787 bg=#0a0a0a"
# END_PALETTE_TMUX
no colour16 references left
```

- [ ] **Step 4: Verify tmux.conf still parses**

Run:

```bash
tmux -L colorscheme-plan-check -f /home/gcharland/.config/tmux/tmux.conf new-session -d \; kill-server
echo "exit: $?"
```

Expected output: `exit: 0` (no tmux error printed above it)

- [ ] **Step 5: Commit**

```bash
cd /home/gcharland/.config
git add tmux/tmux.conf scripts/colorscheme/apply.sh
git commit -m "$(cat <<'EOF'
Sync tmux colors to the canonical palette

tmux.conf previously referenced colour16 for its status bar
background, which is a fixed xterm-256 cube slot independent of
gnome-terminal's customized 16-color palette (only indices 0-15 are
customizable) — so it never actually tracked the terminal's theme.
Switching to explicit hex (already supported via the existing Tc
truecolor override) makes it match unconditionally.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: dunst sync

**Files:**
- Modify: `dunst/dunstrc:72` (global frame_color), `:294-295` (urgency_low), `:301-303` (urgency_normal), `:310-312` (urgency_critical)
- Modify: `scripts/colorscheme/apply.sh` (add `apply_dunst`)

**Interfaces:**
- Consumes: `replace_block` from Task 1.
- Produces: `apply_dunst(file)` — takes one arg (path to dunstrc), regenerates its four marked blocks (`GLOBAL`, `LOW`, `NORMAL`, `CRITICAL`).

- [ ] **Step 1: Wrap the four color-bearing dunstrc regions in markers**

In `dunst/dunstrc`, replace:

```
    # Defines color of the frame around the notification window.
    frame_color = "#292929"
```

with:

```
    # Defines color of the frame around the notification window.
    # BEGIN_PALETTE_GLOBAL
    frame_color = "#292929"
    # END_PALETTE_GLOBAL
```

Replace:

```
[urgency_low]
    # IMPORTANT: colors have to be defined in quotation marks.
    # Otherwise the "#" and following would be interpreted as a comment.
    background = "#222222"
    foreground = "#888888"
    timeout = 10
```

with:

```
[urgency_low]
    # IMPORTANT: colors have to be defined in quotation marks.
    # Otherwise the "#" and following would be interpreted as a comment.
    # BEGIN_PALETTE_LOW
    background = "#222222"
    foreground = "#888888"
    # END_PALETTE_LOW
    timeout = 10
```

Replace:

```
[urgency_normal]
    background = "#292929"
    foreground = "#dfdfdf"
    frame_color = "#406464"
    timeout = 10
```

with:

```
[urgency_normal]
    # BEGIN_PALETTE_NORMAL
    background = "#292929"
    foreground = "#dfdfdf"
    frame_color = "#406464"
    # END_PALETTE_NORMAL
    timeout = 10
```

Replace:

```
[urgency_critical]
    background = "#bd6b73"
    foreground = "#dfdfdf"
    frame_color = "#292929"
    timeout = 0
```

with:

```
[urgency_critical]
    # BEGIN_PALETTE_CRITICAL
    background = "#bd6b73"
    foreground = "#dfdfdf"
    frame_color = "#292929"
    # END_PALETTE_CRITICAL
    timeout = 0
```

- [ ] **Step 2: Add apply_dunst to apply.sh**

In `scripts/colorscheme/apply.sh`, add this function after `apply_tmux`:

```bash
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
```

Then change the bottom of the file from:

```bash
apply_gnome_terminal
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"
apply_tmux "$CONFIG_DIR/tmux/tmux.conf"

echo "Palette applied."
```

to:

```bash
apply_gnome_terminal
apply_i3_like "$CONFIG_DIR/i3/config"
apply_i3_like "$CONFIG_DIR/sway/config"
apply_tmux "$CONFIG_DIR/tmux/tmux.conf"
apply_dunst "$CONFIG_DIR/dunst/dunstrc"

echo "Palette applied."
```

- [ ] **Step 3: Run it and verify all four blocks**

Run:

```bash
/home/gcharland/.config/scripts/colorscheme/apply.sh
sed -n '/# BEGIN_PALETTE_GLOBAL/,/# END_PALETTE_GLOBAL/p;/# BEGIN_PALETTE_LOW/,/# END_PALETTE_LOW/p;/# BEGIN_PALETTE_NORMAL/,/# END_PALETTE_NORMAL/p;/# BEGIN_PALETTE_CRITICAL/,/# END_PALETTE_CRITICAL/p' /home/gcharland/.config/dunst/dunstrc
```

Expected output:
```
# BEGIN_PALETTE_GLOBAL
    frame_color = "#0a0a0a"
# END_PALETTE_GLOBAL
# BEGIN_PALETTE_LOW
    background = "#0a0a0a"
    foreground = "#b2b2b2"
# END_PALETTE_LOW
# BEGIN_PALETTE_NORMAL
    background = "#0a0a0a"
    foreground = "#b2b2b2"
    frame_color = "#406464"
# END_PALETTE_NORMAL
# BEGIN_PALETTE_CRITICAL
    background = "#a75f5f"
    foreground = "#b2b2b2"
    frame_color = "#0a0a0a"
# END_PALETTE_CRITICAL
```

- [ ] **Step 4: Restart dunst and verify it accepts the config**

Run:

```bash
pkill dunst; sleep 1; (dunst &>/tmp/dunst-check.log &); sleep 1
grep -i "error\|fatal\|Unable to parse" /tmp/dunst-check.log || echo "dunst started with no config errors"
```

Expected output: `dunst started with no config errors`

- [ ] **Step 5: Commit**

```bash
cd /home/gcharland/.config
git add dunst/dunstrc scripts/colorscheme/apply.sh
git commit -m "$(cat <<'EOF'
Sync dunst colors to the canonical palette

Replaces dunst's drifted grays (#222222, #292929, #888888) and
off-brand critical red (#bd6b73) with the canonical background/
foreground/color1. The normal-urgency frame color already matched
$main's accent teal and is now emitted from the shared palette
instead of being a hardcoded coincidence.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: End-to-end verification

**Files:** none (verification only)

**Interfaces:**
- Consumes: the fully wired `apply.sh` from Tasks 1-4 (all five apply_* calls present).

- [ ] **Step 1: Confirm apply.sh is idempotent**

Run:

```bash
cd /home/gcharland/.config
cp i3/config /tmp/i3-config-before
cp sway/config /tmp/sway-config-before
cp tmux/tmux.conf /tmp/tmux-conf-before
cp dunst/dunstrc /tmp/dunstrc-before
./scripts/colorscheme/apply.sh
diff /tmp/i3-config-before i3/config && echo "i3/config unchanged"
diff /tmp/sway-config-before sway/config && echo "sway/config unchanged"
diff /tmp/tmux-conf-before tmux/tmux.conf && echo "tmux.conf unchanged"
diff /tmp/dunstrc-before dunst/dunstrc && echo "dunstrc unchanged"
```

Expected output:
```
i3/config unchanged
sway/config unchanged
tmux.conf unchanged
dunstrc unchanged
```

- [ ] **Step 2: Reload i3 and confirm no errors**

Run:

```bash
i3-msg -t command "reload" 2>&1
```

Expected output: `[{"success":true}]`

- [ ] **Step 3: Confirm i3/config and sway/config color blocks are byte-identical**

Run:

```bash
diff <(sed -n '/# BEGIN_PALETTE_I3/,/# END_PALETTE_I3/p' /home/gcharland/.config/i3/config) \
     <(sed -n '/# BEGIN_PALETTE_I3/,/# END_PALETTE_I3/p' /home/gcharland/.config/sway/config) \
  && echo "i3 and sway match"
```

Expected output: `i3 and sway match`

- [ ] **Step 4: Confirm gnome-terminal's live profile matches palette.sh**

Run:

```bash
source /home/gcharland/.config/scripts/colorscheme/palette.sh
uuid=$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")
live_bg=$(dconf read "/org/gnome/terminal/legacy/profiles:/:$uuid/background-color" | tr -d "'")
[ "$live_bg" = "$background" ] && echo "gnome-terminal background matches palette.sh"
```

Expected output: `gnome-terminal background matches palette.sh`

- [ ] **Step 5: Confirm dunst renders all three urgency levels correctly**

Run each and visually confirm the popup background/foreground/frame colors match the values from Task 4 Step 3 (dark background `#0a0a0a`, light text `#b2b2b2`, teal frame `#406464` for normal, red background `#a75f5f` for critical):

```bash
notify-send -u low "Palette check" "low urgency"
sleep 2
notify-send -u normal "Palette check" "normal urgency"
sleep 2
notify-send -u critical "Palette check" "critical urgency"
```

- [ ] **Step 6: Confirm tmux status bar renders with the new colors**

Run:

```bash
tmux -L colorscheme-final-check -f /home/gcharland/.config/tmux/tmux.conf new-session -d -s check
tmux -L colorscheme-final-check attach -t check
```

Visually confirm the status bar background is dark and matches the rest of the palette, then detach (`prefix` + `d`, i.e. `Ctrl-a d` per this config's `set -g prefix C-a`) and run:

```bash
tmux -L colorscheme-final-check kill-server
```

- [ ] **Step 7: No commit needed** — this task is verification-only. If any check in Steps 1-6 fails, return to the relevant earlier task, fix it there, and re-run this task from Step 1.
