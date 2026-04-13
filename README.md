# Dotfiles

My personal Arch Linux configuration and dotfiles.

## Core Stack

- **Shell:** [Fish Shell](https://fishshell.com/)
- **AUR Helper:** [paru](https://github.com/Morganamilo/paru)
- **Symlink Management:** [GNU Stow](https://www.gnu.org/software/stow/)

## Arch Maintenance

Managed via `pacman-contrib`:

- `paccache`: Configured to keep the last 3 versions (`rk3`) and managed via systemd timers.
- `checkupdates`: For safe update checking.
- `pactree`: For dependency visualization.

## Terminal: Ghostty

Keybindings typically use `Shift+Ctrl`:

- `Shift+Ctrl+P`: Command Palette

## Fish Shell

### Functions
- `y.fish`: A wrapper for [yazi](https://github.com/sxyazi/yazi) that integrates with [zoxide](https://github.com/ajeetdsouza/zoxide) to change directories on exit.

### Helper Scripts
To stow scripts:
```bash
stow -vt ~ scripts
```

## CLI Tools

| Category | Packages |
| :--- | :--- |
| **File Management** | `yazi`, `fd`, `fzf`, `ouch` |
| **Search** | `ripgrep`, `ripgrep-all` |
| **Navigation** | `zoxide`, `atuin` |
| **System Info** | `eza`, `duf`, `bat`, `bat-extras` |
| **Git** | `lazygit`, `gh` |
| **Editor** | `nvim` |

## Development

- **Python:** Managed with [`uv`](https://github.com/astral-sh/uv).
