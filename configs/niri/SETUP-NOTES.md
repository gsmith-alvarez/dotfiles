# Niri Setup Notes

## System

- **NixOS 26.11** (nixos-unstable), managed by the flake at `~/dotfiles` (`flake.nix`, `home/`, `modules/`, `hosts/`, `configs/`)
- Home-manager symlinks configs with `mkOutOfStoreSymlink` → they resolve to `~/dotfiles/configs/...`, so **edits apply instantly without a rebuild**
- Rebuild with `sudo nixos-rebuild switch --flake ~/dotfiles#<host>` when packages/modules change

## Screenshot Setup

**Keybindings** (in `config.kdl`):
- `Super+Shift+S` → `~/.local/bin/niri-screenshot.sh` (smart mode: slurp overlay with rects for the focused output + every visible window; a tiny drag = click, which expands to the rect under the cursor)
- `Super+Shift+F` → Noctalia fullscreen screenshot (`noctalia msg screenshot-fullscreen`)
- `Ctrl+Shift+S` → Niri's built-in screenshot UI

**Script:** `~/dotfiles/configs/scripts/niri-screenshot.sh` (symlinked to `~/.local/bin/niri-screenshot.sh`)
- Modes: `smart` (default), `region`, `fullscreen`, `window`
- Saves to `~/Pictures/Screenshots/screenshot-<timestamp>.png`, copies to clipboard (`wl-copy`)
- Saves + copies, then sends a notification — clicking it opens the shot in **satty** for annotation
- Uses `grim` + `slurp` + `satty` + `wl-copy`

## Desktop Shell: Noctalia

**Noctalia** (`noctalia` v5.1.0, installed via the flake's `noctalia` GitHub input + cachix):
- QtQuick desktop shell: floating top bar (compact), system tray, clock, workspace indicator, widgets
- App launcher (`Super+Space`), control center (`Super+A`), settings UI (`Super+Comma`) via `noctalia msg panel-toggle ...`
- Notification daemon with history, toasts (battery, keyboard layout)
- Own lock screen: `Super+Escape` → `noctalia msg session lock`; locks on suspend
- Wallpaper: directory `~/Pictures/Wallpapers` (wallpaper rendering disabled — plain background)
- Volume/brightness media keys route through `noctalia msg volume-up` etc.

**Noctalia greeter** (login screen, NixOS module `noctalia-greeter`):
- Default user `giovanni`, default session `Niri`, per-output scales (`DP-1`/`DP-2`: 1.5, `eDP-1`: 1.25)
- Settings in `~/dotfiles/modules/desktop/default.nix`

**Noctalia settings:** `~/.config/noctalia/settings.json` (bar, launcher, notifications, idle, lock screen)

## Autostart Programs

All in `config.kdl` spawn-at-startup:
1. `noctalia` — desktop shell
2. `easyeffects -w` — audio DSP
3. `wayscriber -d` — screen annotation daemon

## Theme
- Focus ring: Mauve `#cba6f7` (active), `#505050` (inactive), width 2px
- Rounded corners 12px, window opacity 0.85, background blur, soft shadows

## Keybindings Summary

| Key | Action |
|---|---|
| Super+Space | App launcher (Noctalia) |
| Super+A | Control center (Noctalia) |
| Super+Comma | Noctalia settings |
| Super+Return | Terminal (ghostty) |
| Super+D | Screen annotation (wayscriber toggle) |
| Super+Shift+S | Screenshot (smart mode: window/region snapping) |
| Super+Shift+F | Fullscreen screenshot (Noctalia) |
| Ctrl+Shift+S | Niri built-in screenshot UI |
| Super+Escape | Lock screen (Noctalia) |
| Super+Alt+B | Zen browser |
| Super+Alt+O | Obsidian |
| Super+Alt+Z | Zed |
| Super+Alt+K | KeePassXC |
| Super+Alt+M | Thunderbird |
| Super+Alt+S | Toggle screen reader (orca) |
| Alt+Tab / Alt+Shift+Tab | Recent windows (per output) |
| Alt+` / Alt+Shift+` | Recent windows, same app |
| Super+Q | Close window |
| Super+J/K, Super+Up/Down | Focus workspace |
| Super+H/L, Super+Left/Right | Focus column |
| Super+Shift+H/J/K/L | Focus monitor |
| Super+M | Maximize window to edges |
| Super+C | Center column |
| Super+Shift+R | Cycle preset column widths |
| Ctrl+Alt+Delete | Quit niri |

Full list in `config.kdl` `binds {}` or the niri hotkey overlay (Skipped at startup; check niri's hotkey overlay).

## Niri Config Details

**File:** `~/dotfiles/configs/niri/config.kdl` (→ `~/.config/niri/config.kdl`)

**Keyboard:** US layout, numlock on, repeat delay 600ms, rate 25hz

**Outputs:**
- `DP-1`, `DP-2`: 3840x2160@144, scale 1.5, VRR on-demand — `DP-1` at x=0, `DP-2` at x=2560
- `eDP-1`: disabled (commented out)

**Workspaces:**
- `study` on `DP-1` — zen, Obsidian open there at startup
- `utils` on `DP-2` — KeePassXC, Thunderbird, ghostty open there at startup

**Window behavior:** focus-follows-mouse (max-scroll 0%), gaps 8, rounded corners 12px, always-center-single-column, preset widths ⅓/½/⅔ (default ½)

**Window rules:** terminals get border-without-background; settings apps (pavucontrol, nm-connection-editor...) open tiled at ½ width; calculators/Nautilus/portal float; Firefox PiP and zoom float; Noctalia window floats at 1080x920; all windows get radius 12 + opacity 0.85 + blur

## Packages of Note

Installed via the flake (`~/dotfiles/home/dotfiles.nix`, `~/dotfiles/modules/`):
- `noctalia`, `noctalia-greeter` — desktop shell + login greeter (GitHub inputs, cachix)
- `niri` — compositor (NixOS module `programs.niri`)
- `grim`, `slurp`, `satty`, `wl-clipboard`, `cliphist` — screenshot tooling
- `wayscriber`, `easyeffects`, `ghostty`, `zed-editor`, `spotify-player`, `jq`
- Portal: `xdg-desktop-portal-gtk`; Polkit agent: `polkit_gnome` (systemd user service)

## Files / Config Locations

- `~/dotfiles/configs/niri/config.kdl` — main Niri config (→ `~/.config/niri/config.kdl`, instant-apply symlink)
- `~/dotfiles/configs/scripts/niri-screenshot.sh` — screenshot script (→ `~/.local/bin/niri-screenshot.sh`)
- `~/dotfiles/configs/niri/SETUP-NOTES.md` — this file
- `~/dotfiles/home/dotfiles.nix` — home-manager packages + config symlinks
- `~/dotfiles/modules/desktop/default.nix` — NixOS desktop module (noctalia, greeter, niri, portals, polkit)
- `~/.config/noctalia/settings.json` — Noctalia shell settings

## Audio

- **EasyEffects** autostarts with `-w` (windowed daemon); presets in `~/dotfiles/configs/easy-effects/`
- **Discord pausing Spotify on call join:** WirePlumber's `linking.pause-playback` pauses MPRIS players when an audio sink is removed (triggered by Discord's voice engine). Currently still at its default `true` on this machine. If it bites, fix with:
  ```
  wpctl settings linking.pause-playback false
  wpctl settings --save linking.pause-playback
  ```
  Persisted in `~/.local/state/wireplumber/sm-settings`.
