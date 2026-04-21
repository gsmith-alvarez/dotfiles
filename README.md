# Dotfiles

My personal Arch Linux configuration and dotfiles, featuring **Cosmic DE** and the **Catppuccin** color scheme.

## Core Stack

- **Desktop Environment:** [Cosmic DE](https://github.com/pop-os/cosmic-epoch)
- **Shell:** [Fish Shell](https://fishshell.com/)
- **AUR Helper:** [paru](https://github.com/Morganamilo/paru)
- **Symlink Management:** [GNU Stow](https://www.gnu.org/software/stow/)
- **Theme:** [Catppuccin](https://catppuccin.com/)

## Installation

Currently managed manually via GNU Stow. 

```bash
# Example: stow a package
stow -vt ~ package_name
```

TODO: Make a script for it

## Arch Maintenance

Managed via `pacman-contrib`:

- `paccache`: Configured to keep the last 3 versions (`rk3`) and managed via systemd timers.
- `checkupdates`: For safe update checking.
- `pactree`: For dependency visualization.
- `topgrade`: Used for managing miscellaneous updates.

## Terminal & UI

- **Terminal:** [Ghostty](https://ghostty.org/) (Keybindings typically use `Shift+Ctrl`)
- **Terminal Font:** [Monaspace Krypton](https://monaspace.githubnext.com/)
- **GUI Font:** [Monaspace Neon](https://www.programmingfonts.org/#monaspace-neon)

## Development Environment

- **Python:** Managed with [`uv`](https://github.com/astral-sh/uv).
- **Version Manager:** [`mise`](https://mise.jdx.dev/) for handling various dev runtimes.
- **Containers:** Preferring [Podman](https://podman.io/) and [Distrobox](https://github.com/89luca89/distrobox).
- **Editor:** [Neovim](https://neovim.io/) (Built weekly from nightly).

## CLI Tools

| Category | Packages |
| :--- | :--- |
| **File Management** | `yazi`, `fd`, `fzf`, `ouch` |
| **Search** | `ripgrep`, `ripgrep-all` |
| **Navigation** | `zoxide`, `atuin` |
| **System Info** | `eza`, `duf`, `bat`, `bat-extras` |
| **Git** | `lazygit`, `gh` |
| **Music** | `spotify-player` |

## System & Peripherals

- **Clipboard:** `wl-clipboard` with `cliphist`.
- **Graphics Tablet:** [OpenTabletDriver](https://opentabletdriver.net/) + `wayscriber`.

## Fish Shell Details

### Functions
- `y.fish`: A wrapper for [yazi](https://github.com/sxyazi/yazi) that integrates with [zoxide](https://github.com/ajeetdsouza/zoxide) to change directories on exit.

### Helper Scripts
To stow scripts:
```bash
stow -vt ~ scripts
```
