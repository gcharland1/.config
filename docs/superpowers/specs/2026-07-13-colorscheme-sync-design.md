# Colorscheme sync across i3/sway, gnome-terminal, tmux, dunst, zsh

## Context

i3/sway currently define a handful of ad-hoc color variables (`$black`, `$main`,
`$red`, `$white`, `$yellow`, `$blue`) that were hand-picked to loosely match the
look of gnome-terminal, but the values aren't identical and there's no single
source of truth. tmux references raw ANSI-256 cube/grayscale indices
(`colour16`, `colour6`, `colour7`, `colour8`) which are independent of the
terminal's customized 16-color palette, so it doesn't actually track the same
scheme. dunst has a few colors that were clearly meant to match (`#406464`,
`#dfdfdf`) alongside others that drifted (`#222222`, `#292929`, `#888888`,
`#bd6b73`). The goal is one canonical palette that every tool pulls from, so a
future color change only requires editing one file.

kitty and byobu are explicitly out of scope (kitty isn't currently used;
byobu's Ubuntu-branded accents are being left alone).

## Canonical source

gnome-terminal's current default profile (`background-color`, `foreground-color`,
`palette`) is the canonical source. It already defines a complete 16-slot ANSI
palette in a muted "xterm-cube" style, and is the terminal actually in daily
use (confirmed via running process). Nothing new is invented — i3/sway's
existing accent colors (`$red`, `$yellow`, `$blue`, `$main`) already sit close
to this palette; this work formalizes and exactly aligns them.

i3/sway's `$black`/`$white` will be changed to exactly match the terminal's
`background`/`foreground` (previously `#131313`/`#dfdfdf`, close but not
identical to `#0a0a0a`/`#b2b2b2`). `$main` (`#406464`, the teal UI accent used
for window borders and dunst's normal-urgency frame) is kept as a separate,
non-ANSI "accent" slot in the palette file, since it doesn't correspond to any
of gnome-terminal's 16 colors.

## Palette file

New file: `scripts/colorscheme/palette.sh` — plain bash variable assignments,
the only place colors are hand-edited going forward:

```bash
background="#0a0a0a"
foreground="#b2b2b2"

color0="#0a0a0a";  color8="#5f5f5f"    # black
color1="#a75f5f";  color9="#a75f5f"    # red
color2="#5f875f";  color10="#5f875f"   # green
color3="#a7873f";  color11="#a7873f"   # yellow
color4="#5f5fa7";  color12="#5f5fa7"   # blue
color5="#875f87";  color13="#875f87"   # magenta
color6="#5f8787";  color14="#5f8787"   # cyan
color7="#b2b2b2";  color15="#e4e4e4"   # white

accent="#406464"                        # UI accent (i3 borders, dunst normal frame) — not an ANSI slot
```

Bright variants (8-15) currently equal their normal counterpart except white,
matching gnome-terminal's existing palette as-is.

## Generator script

`scripts/colorscheme/apply.sh` sources `palette.sh` and rewrites each target
in place, idempotently, using marker-delimited blocks so hand-written config
around them is untouched:

- **i3/config, sway/config** — replace the `set $black/$main/$red/$white/
  $yellow` block between `# BEGIN_PALETTE_I3` / `# END_PALETTE_I3` markers
  (mirroring the `# BEGIN_KITTY_THEME`/`# END_KITTY_THEME` convention already
  used in `kitty/kitty.conf`). i3/config no longer defines `$blue` (dropped in
  a manual edit in favor of reusing `$main` for the launcher's prompt/highlight
  text) — sway/config still has the old `$blue` var and references; this sync
  also removes it there and switches sway's launcher bindings to `$main`, so
  both files match exactly.
- **gnome-terminal** — not a file. The script looks up the live default
  profile UUID via `dconf read /org/gnome/terminal/legacy/profiles:/default`
  (never hardcoded) and runs `dconf write` for `background-color`,
  `foreground-color`, and `palette`.
- **tmux/tmux.conf** — replace the `colour16`/`colour6`/`colour7`/`colour8`
  references (fixed cube/grayscale slots, independent of the customized
  palette) with real `#rrggbb` hex, inside a marked block.
  `terminal-overrides ",xterm-256color:Tc"` is already present in the file,
  so true-color hex works with no other change.
- **dunst/dunstrc** — replace the mismatched grays (`#222222`, `#292929`,
  `#888888`) and the off-brand critical red (`#bd6b73`) with the canonical
  `background`/`foreground`/`color1`, inside a marked block. The existing
  `#406464` normal-urgency frame color already matches `accent` and is left
  as-is (re-emitted from the `accent` variable rather than hardcoded).

## zsh — no change needed

The active oh-my-zsh theme (`eastwood`) uses `$fg[red]`/`$fg[yellow]`/
`$fg[cyan]` — oh-my-zsh's named ANSI-color macros — which resolve through the
terminal's own palette at render time. Once gnome-terminal's palette is
canonical, the zsh prompt is automatically in sync. No file is written for
zsh.

## Verification

After running `apply.sh`:

1. `i3-msg reload` and confirm no config errors.
2. Diff the generated color block in `sway/config` against `i3/config` to
   confirm they match.
3. Open a fresh gnome-terminal window/tab and inspect its colors via
   `dconf read` against `palette.sh`.
4. Kill and let tmux respawn its status bar; confirm colors visually.
5. `notify-send` at low/normal/critical urgency and visually confirm dunst
   colors, including the untouched `accent` frame color.
