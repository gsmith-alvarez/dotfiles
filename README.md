# .dotfiles

Personal configuration for a Fedora-based embedded engineering workstation.
Managed with [GNU Stow](https://www.gnu.org/software/stow/) — all configs live
at the repo root and are symlinked into `~/.config/`.

---

## Bootstrap

```bash
git clone https://github.com/gsmith-alvarez/.dotfiles.git ~/dotfiles
cd ~/dotfiles

# create symlinks and install mise-managed tools
stow --target ~/.config .
mise install
```

`stow` will create symlinks for every directory/file at the repo root into
`~/.config/`. Files listed in `.stow-local-ignore` (`README.md`, `reference.md`,
`.gitignore`, `.git`) are excluded.

For full provisioning details — packages, hardware, kernel tuning, Flatpaks, firewall, and mise portability — see [**QUICKSTART.md**](QUICKSTART.md).

---

## Configs

| Directory / File | Tool |
|---|---|
| `nvim/` | Neovim — mini.nvim + snacks.nvim, no Mason, mise-managed LSPs |
| `fish/` | Fish shell — functions, abbreviations, `zs` session manager |
| `zellij/` | Zellij — multiplexer layouts (health, dashboard) |
| `ghostty/` | Ghostty terminal emulator |
| `mise/` | mise — language runtime & tool version manager (see [QUICKSTART.md § Runtime Toolchain](QUICKSTART.md#2-runtime-toolchain)) |
| `atuin/` | Atuin — shell history sync |
| `carapace/` | Carapace — multi-shell completion bridge |
| `lazygit/` | Lazygit |
| `starship.toml` | Starship prompt |
| `topgrade.toml` | Topgrade system updater |
| `btop/` | btop resource monitor |
| `bottom/` | bottom (btm) resource monitor |
| `aichat/` | aichat CLI AI client |
| `glow/` | Glow markdown renderer |
| `spotify-player/` | spotify-player TUI |
| `yazu/` | Yazi file manager |
| `cosmic/` | COSMIC desktop settings |
| `easy-effects/` | EasyEffects audio presets |
| `mimeapps.list` | XDG MIME type associations |

---

## Neovim

Lightweight, portable config built on three pillars — see [`nvim/README.md`](nvim/README.md) for the full architecture, plugin inventory, and keymap registry.

**Key design choices:**
* No Mason — all LSPs, formatters, and tools managed by `mise`
* `mini.deps` for plugin management (no lazy.nvim)
* `snacks.nvim` for picker, notifications, and terminal
* `blink.cmp` for completion
* Circuit-breaker pattern: every plugin load is wrapped in `pcall`
* `lua/core/vscode.lua` bridges leader maps to VSCode commands when running inside vscode-neovim
