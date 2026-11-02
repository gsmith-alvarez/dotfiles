# Keybinding register

The current Nix configuration keeps keyboard ownership split by layer:

| Modifier | Layer | Owner |
| --- | --- | --- |
| `Mod` | Compositor | Niri and Noctalia |
| `Alt` | Window switching / editor helpers | Niri recent-windows and Neovim |
| `Space` | Editor leader | Neovim |
| `Ctrl` | Editor and terminal | Neovim and Ghostty |

## Rules

- Niri must not bind bare `Ctrl+X` or bare `Alt+X` combinations.
- The `Alt+Tab` / `Alt+Shift+Tab` / `Alt+grave` / `Alt+Shift+grave` recent-window family is the sanctioned bare-Alt exception.
- `Ctrl+Alt+Delete` remains the explicit compositor quit chord.
- Ghostty must not bind `Mod` or `Super`; `Ctrl+Alt` and `Ctrl+Shift` remain terminal-owned.
- Wayscriber: `Mod+D` toggles the daemon; `Mod+Alt+L` toggles light passthrough; `Mod+Alt+D` toggles light drawing.

## Source files

- Compositor: `configs/niri/config.kdl`
- Terminal: `configs/ghostty/config`
- Editor: `configs/nvim/plugin/03-keymaps.lua` and `configs/nvim/plugin/04-plugin-keymaps.lua`
- Shell: `configs/fish/config.fish`

Run the checker after changing one of these layers:

```bash
./scripts/check-layers.sh
niri validate -c configs/niri/config.kdl
```
