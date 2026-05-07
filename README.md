# Dotfiles

Personal Fedora configuration featuring Cosmic DE and the Catppuccin Mocha theme.

## Core Stack

- **Desktop Environment:** [Cosmic DE](https://github.com/pop-os/cosmic-epoch)
- **Shell:** [Fish Shell](https://fishshell.com/)
- **Theme:** [Catppuccin Mocha](https://catppuccin.com/)
- **Terminal:** [Ghostty](https://ghostty.org/) (Monaspace Krypton NF font, background blur)
- **Prompt:** [Starship](https://starship.rs/)
- **System Provisioner:** [init.sh](init.sh) (updates, DNF/Flatpak packages, systemd services)

## Highlights

### fnav (Fish Navigation)
Fuzzy directory navigator combining [fd](https://github.com/sharkdp/fd), [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide), and [eza](https://github.com/eza-community/eza).
- `fnav` / `d`: Fuzzy search subdirectories.
- `fnav up` / `u`: Fuzzy search parent directories.
- `fnav zoxide` / `z`: Fuzzy search zoxide database.
- Displays eza tree previews and toggles hidden files.

### Yazi File Manager
[Yazi](https://github.com/sxyazi/yazi) file manager with plugins:
- [ouch](https://github.com/pypa/ouch): Archive preview and extraction.
- `git`: Real-time status display.
- Plugins: `smart-filter`, `chmod`, `mount`, `jump-to-char`.

### Development
- **[Mise](https://mise.jdx.dev/):** Runtime manager (Node, Bun, Zig) and LSPs (Pyright, Bash, JSON, YAML).
- **[Neovim](https://neovim.io/):** Nightly builds with custom runner system and UI additions (blink.cmp, snacks.nvim, dropbar.nvim, mini.nvim).
- **Containers:** Podman and Distrobox.
- **Clipboard:** wl-clipboard and cliphist.

### System & Audio
- **Graphics Tablet:** OpenTabletDriver and wayscriber.
- **Media:** spotify-player and Easy Effects.

## Installation

Deploy configurations using the stow script:

```bash
./stow.sh
```

Or manually:

```bash
stow -vt ~ package_name
```

## Fish Abbreviations

| Abbr | Command | Description |
| :--- | :--- | :--- |
| `v` | `nvim` | Edit with Neovim |
| `ls` | `eza ...` | List files with eza |
| `rg` | `batgrep` | Search text with bat-extras |
| `cat` | `bat` | View file with bat |
| `find` | `fd` | Find files with fd |
| `ch` | Cliphist selector | View clipboard history |
| `copy` | `wl-copy` | Copy to clipboard |
| `paste` | `wl-paste` | Paste from clipboard |
| `u`/`d`/`z` | `fnav ...` | Navigate directories |
