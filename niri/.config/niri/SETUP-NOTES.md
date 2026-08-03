# Niri Setup Notes

## Screenshot Setup (Windows Snipping Tool style)

**Keybindings** (in `config.kdl`):
- `Super+Shift+S` → Screenshot mode picker (fuzzel menu: Region / Active Monitor / All Monitors)
- `Super+Shift+F` → Quick full screen capture (no menu)

**Every capture:**
- Saves to `~/Pictures/Screenshots/`
- Copies to clipboard automatically
- Shows notification via DMS notification daemon (all handled by DMS)

**Script:** `~/dotfiles/niri/.config/niri/dms/scripts/screenshot.sh` (stowed to `~/.config/niri/dms/scripts/screenshot.sh`, symlinked from `~/.local/bin/niri-screenshot.sh`)
- Uses `dms screenshot` commands — DMS's built-in screenshot module (region, full, all)
- Handles clipboard + notification automatically
- No external dependencies (no grim, slurp, or wl-copy)

## Launcher Setup

**App launcher** (Super+Space): Opens `fsel` inside a borderless Ghostty window
```
Super+Space → ghostty --window-decoration=none --title=fsel -e fsel --detach
```
Window rule in `config.kdl` makes it float at natural size.

Also available via `Mod+D` (kept as fallback).

**Screenshot mode picker:** Uses `fuzzel` (Wayland-native layer-shell popup)
- fsel is terminal-only (no Wayland rendering) — can't do popup overlays
- fuzzel is actively maintained (last commit July 25, 2026, codeberg.org/dnkl/fuzzel)

## Desktop Shell & Notifications

**quickshell DMS** (`dms run --session`):
- QtQuick-based desktop shell from the `danklinux` Copr repo
- Provides top bar with system tray, clock, workspace indicator, interactive widgets
- Built-in notification center (bell icon), control center (volume/network/bluetooth), calendar popup
- Handles wallpaper via `dms ipc call wallpaper set <path>` or `dms screenshot` for capture
- Manages idle/suspend (AC: 5min→10min→30min, Battery: 3min→5min→15min)
- Provides its own PolKit agent for admin prompts
- Provides its own lock screen (DMS themed)
- Owns `org.freedesktop.Notifications` on D-Bus

**DMS first-launch greeter** — shows setup wizard + config doctor on first run:
- To re-trigger: `rm ~/.config/DankMaterialShell/.firstlaunch` then restart DMS
- Or run `dms doctor` in terminal for config health check

**DMS fonts** (set in `~/.config/DankMaterialShell/settings.json`):
- UI font: Inter
- Monospace font: Monaspace Krypton NF (matches COSMIC)

## Autostart Programs

All in `config.kdl` spawn-at-startup (in order):
1. `dms run --session` — quickshell DMS (top bar, wallpaper, notifications, idle, polkit, lock screen, system tray)

## Theme

Catppuccin Mocha inspired:
- Focus ring: Mauve `#cba6f7`, width 2px
- Rounded corners: 12px on all windows via geometry-corner-radius
- Fuzzel: Catppuccin Mocha theme (`~/.config/fuzzel/fuzzel.ini`)

## Keybindings Summary

| Key | Action |
|---|---|
| Super+Space | App launcher (fsel in ghostty) |
| Super+Return | Terminal (ghostty) |
| Super+D | Screen annotation (wayscriber toggle) |
| Super+Shift+S | Screenshot menu (region/monitor/all) |
| Super+Shift+F | Quick full screen capture |
| Super+Alt+L | Lock screen (DMS) |
| Mod+D | App launcher fallback (fsel) |

## Niri Config Details

**File:** `~/.config/niri/config.kdl`

**Keyboard:** US layout, caps:swapescape, repeat delay 600ms, rate 25hz

**Window behavior:** focus-follows-mouse, gaps 8, rounded corners 12px

**Window rules:**
- Ghostty with title "fsel" → floating, natural size
- All windows → geometry-corner-radius 12, clip-to-geometry

## Packages Installed

- `xdg-desktop-portal-wlr` — wlroots portal backend (niri added to UseIn)
- `quickshell` 0.3.0 — QtQuick desktop shell (from danklinux Copr)
- `dms-cli` 1.5.3 — DMS management CLI (from danklinux Copr)

## Files / Config Locations

- `~/.config/niri/config.kdl` — main Niri config (keybindings, window rules, autostarts)
- `~/.config/niri/dms/scripts/screenshot.sh` — screenshot menu script (symlinked to ~/.local/bin/)
- `~/.config/niri/SETUP-NOTES.md` — this file
- `~/.config/niri/dms/` — DMS compositor configs (binds.kdl, colors.kdl, layout.kdl, etc.)
- `~/.config/DankMaterialShell/settings.json` — DMS settings (fonts, theme, behavior)
- `~/.config/DankMaterialShell/.firstlaunch` — first-launch marker (remove to re-trigger greeter)

## Future Options

**khal** — CLI calendar backend for DMS (shows events in clock popup):
- `sudo dnf install khal`
- DMS auto-detects it as a calendar backend

**walker** (v2.17.0, Terra repo) could replace fuzzel eventually:
- Wayland-native layer-shell popup with `--dmenu` mode
- Built-in modules: web search, calculator, clipboard history, emoji picker
- Decision: wait for it to mature
