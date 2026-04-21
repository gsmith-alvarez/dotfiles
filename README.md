# Dotfiles

My personal Arch Linux configuration and dotfiles, featuring **Cosmic DE** and the **Catppuccin** color scheme.

## Core Stack

- **Desktop Environment:** [Cosmic DE](https://github.com/pop-os/cosmic-epoch)
- **Shell:** [Fish Shell](https://fishshell.com/)
- **AUR Helper:** [paru](https://github.com/Morganamilo/paru)
- **Symlink Management:** [GNU Stow](https://www.gnu.org/software/stow/)
- **Theme:** [Catppuccin Mocha](https://catppuccin.com/)

## Highlights

### 🚀 `fnav` (Fish Navigation)
A custom fuzzy directory navigator that combines [`fd`](https://github.com/sharkdp/fd), [`fzf`](https://github.com/junegunn/fzf), [`zoxide`](https://github.com/ajeetdsouza/zoxide), and [`eza`](https://github.com/eza-community/eza).
- `fnav` / `d`: Fuzzy search subdirectories.
- `fnav up` / `u`: Fuzzy search parent directories.
- `fnav zoxide` / `z`: Fuzzy search zoxide database.
- Features integrated `eza` tree previews and hidden file toggles.

### 📁 [Yazi](https://github.com/sxyazi/yazi) File Manager
Highly customized with specialized plugins:
- [`ouch`](https://github.com/pypa/ouch): Archive preview and extraction.
- `git`: Real-time git status in the file manager.
- `smart-filter`: Intelligent file filtering.
- Plugins for `chmod`, `mount`, and `jump-to-char`.

### ⚡ Development Tools
- **[Mise](https://mise.jdx.dev/):** Manages runtimes ([Node](https://nodejs.org/), [Bun](https://bun.sh/), [Zig](https://ziglang.org/)) and LSPs (Pyright, Bash, JSON, YAML).
- **[Neovim](https://neovim.io/):** Nightly builds with a custom modular config.
    - Custom "Building" system for running/executing code.
    - UI enhancements: [`blink.cmp`](https://github.com/Saghen/blink.cmp), [`snacks.nvim`](https://github.com/folke/snacks.nvim), [`dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim), [`mini.nvim`](https://github.com/echasnovski/mini.nvim).
- **Containers:** Native [Podman](https://podman.io/) and [Distrobox](https://github.com/89luca89/distrobox) workflow.

## Installation

Currently managed manually via GNU Stow. 

```bash
# Example: stow a package
stow -vt ~ package_name
```

## Arch Maintenance

Managed via [`pacman-contrib`](https://archlinux.org/packages/extra/x86_64/pacman-contrib/):
- `paccache`: Last 3 versions (`rk3`) via systemd timers.
- `checkupdates`: Safe update checking.
- [`topgrade`](https://github.com/topgrade-rs/topgrade): Aggregate update manager.

## Terminal & UI

- **Terminal:** [Ghostty](https://ghostty.org/)
    - **Font:** [`Monaspace Krypton NF`](https://monaspace.githubnext.com/) (with ligatures and texture healing).
    - **Features:** Background blur, split navigation (`Ctrl+Alt+H/J/K/L`).
- **Prompt:** [Starship](https://starship.rs/)
- **Clipboard:** [`wl-clipboard`](https://github.com/bugaevc/wl-clipboard) + [`cliphist`](https://github.com/sentriz/cliphist) (integrated into `fzf` via Fish abbreviation `ch`).

## System & Peripherals

- **Graphics Tablet:** [OpenTabletDriver](https://opentabletdriver.net/) + `wayscriber`.
- **Music:** [`spotify-player`](https://github.com/aiko-chan-ai/spotify-player). + [Easy Effects](https://github.com/wwmm/easyeffects)

## Fish Abbreviations

| Abbr | Command | Tool |
| :--- | :--- | :--- |
| `v` | `nvim` | [Neovim](https://neovim.io/) |
| `ls` | `eza ...` | [eza](https://github.com/eza-community/eza) |
| `rg` | `batgrep` | [bat-extras](https://github.com/eth-p/bat-extras) |
| `cat` | `bat` | [bat](https://github.com/sharkdp/bat) |
| `find` | `fd` | [fd](https://github.com/sharkdp/fd) |
| `ch` | Cliphist selector | [cliphist](https://github.com/sentriz/cliphist) |
| `copy`/`paste` | `wl-copy` / `wl-paste` | [wl-clipboard](https://github.com/bugaevc/wl-clipboard) |
| `u`/`d`/`z` | `fnav ...` | [fnav](fish/.config/fish/functions/fnav.fish) |
