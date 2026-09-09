# Dotfiles

Modular NixOS and Home Manager configuration for `wolfgang`. Runs [niri](https://github.com/YaLTeR/niri) with [Noctalia](https://github.com/noctalia-dev/noctalia), managed as a unified NixOS flake with live out-of-store symlinked application configs.

## Stack

- **OS / Init**: NixOS (unstable branch, `linuxPackages_latest`)
- **Compositor**: [niri](https://github.com/YaLTeR/niri) (scrollable-tiling Wayland compositor)
- **Desktop Shell & Greeter**: [Noctalia](https://github.com/noctalia-dev/noctalia) + [Noctalia Greeter](https://github.com/noctalia-dev/noctalia-greeter)
- **Terminal**: [Ghostty](https://ghostty.org/)
- **Shell**: [Fish](https://fishshell.com/) + [Starship](https://starship.rs/) + [Atuin](https://atuin.sh/)
- **Editor**: [Neovim](https://neovim.io/) (via `neovim-nightly-overlay`)
- **File Manager**: [Yazi](https://github.com/sxyazi/yazi)
- **System Management**: [nh](https://github.com/viperML/nh) + [Home Manager](https://github.com/nix-community/home-manager)

## Repository Structure

```
dotfiles/
├── flake.nix               # Flake entry point (nixosConfigurations.wolfgang)
├── flake.lock              # Pinned input locks
├── hosts/
│   └── wolfgang/           # Host-specific settings & hardware-configuration.nix
├── modules/
│   ├── core/               # System baseline: PipeWire, fonts, nh, fish, nix-ld
│   └── desktop/            # Desktop stack: Niri, Noctalia shell/greeter, XDG portals
├── home/
│   ├── default.nix         # User packages, Flatpaks, Home Manager integration
│   └── dotfiles.nix        # Out-of-store symlink mappings into configs/
├── configs/                # Live application configurations (symlinked out of store)
│   ├── atuin/              # Shell history sync
│   ├── fish/               # Fish config, abbrs, custom functions (fnav, ndiff)
│   ├── ghostty/            # Ghostty terminal config and themes
│   ├── lazygit/            # Git TUI config with delta integration
│   ├── niri/               # Niri compositor config (config.kdl)
│   ├── nvim/               # Lua-based Neovim configuration
│   ├── yazi/               # Yazi file manager configuration and keymaps
│   ├── .gitconfig          # Git base config and credential helpers
│   └── starship.toml       # Prompt configuration
└── assets/                 # Wallpaper and media assets
```

## Out-of-Store Symlink Pattern

Application configs inside `configs/` are linked via `config.lib.file.mkOutOfStoreSymlink` in `home/dotfiles.nix`:

- Target: `${config.home.homeDirectory}/dotfiles/configs/<path>`
- Destination: `~/.config/<path>` (and `~/.gitconfig`)

Edits made to files in `configs/` take effect immediately without requiring `nh os switch` or Home Manager rebuilds.

## Workflow & Commands

### Switching & Rebuilding

System deployments use `nh` targeting `nixosConfigurations.wolfgang`:

```bash
# Switch to current configuration
nh os switch .

# Dry-run / test build without activating
nh os test .

# Update all flake inputs and switch
nh os switch -u .
```

### Useful Fish Abbreviations

| Abbr | Command | Description |
| :--- | :--- | :--- |
| `nsw` | `nh os switch` | Rebuild and activate current system configuration |
| `nrb` | `nh os boot` | Rebuild system and configure for next boot |
| `ncu` | `nix flake update --flake ~/dotfiles` | Update flake inputs |
| `ncl` | `nh clean all` | Garbage collect old generations |
| `v` | `nvim` | Launch Neovim |
| `gd` | `git diff` | Git diff |
| `cnavi` | `navi --cheatsh` | Interactive cheat sheets |
| `fnav` | `fnav` | Fuzzy directory navigator (fzf + zoxide + eza) |

### Key Modifier Convention

Shortcut layers are segregated across tools to prevent chord collisions:

- `Super` (`Mod`): Window manager / compositor ([niri](configs/niri/config.kdl))
- `Alt`: Terminal emulator ([Ghostty](configs/ghostty/config))
- `Space` (`<leader>`): Editor commands ([Neovim](configs/nvim/plugin/03-keymaps.lua))
