# Dotfiles

Personal Fedora configuration featuring [niri](https://github.com/YaLTeR/niri) + DMS and the Catppuccin Mocha theme, managed with [Home Manager](https://nix-community.github.io/home-manager/).

## Core Stack

- **Desktop:** [niri](https://github.com/YaLTeR/niri) + [DMS](https://github.com/AvengeMedia/DankMaterialShell)
- **Shell:** [Fish Shell](https://fishshell.com/)
- **Theme:** [Catppuccin Mocha](https://catppuccin.com/)
- **Terminal:** [Ghostty](https://ghostty.org/)
- **Prompt:** [Starship](https://starship.rs/)
- **Config management:** Home Manager flake (this repo is the source of truth)
- **System Provisioner:** [scripts/init.sh](scripts/init.sh) (updates, DNF/Flatpak packages, systemd services)

## Structure

```
dotfiles/
├── flake.nix            # HM entry point — homeConfigurations.laptop / .desktop
├── hosts/               # Machine-specific HM modules + niri outputs
│   ├── laptop/          #   eDP-1 (built-in panel)
│   └── desktop/         #   DP-3 + HDMI-A-1, study/utils workspaces
├── modules/             # Shared HM modules (editor, git, terminal, services, agents)
├── packages/            # Custom Nix packages / overlay
├── configs/             # Native config files (flat, no stow nesting)
│   ├── fish/  nvim/  niri/  ghostty/  yazi/  ...
│   └── ...
└── scripts/             # init.sh provisioner, cleanup.sh
```

Configs stay in their **native formats** (`.kdl`, `.lua`, `.toml`) and are
symlinked **out-of-store** by Home Manager — edit a file in `configs/` and the
change applies live, no `home-manager switch` needed.

Machine-specific niri settings (outputs, workspaces) live in
`hosts/<host>/niri-outputs.kdl` and are included last by
`configs/niri/config.kdl` (`include "outputs.kdl"`), so they win over the
DMS-generated includes.

## Deploying

```bash
# Laptop
home-manager switch --flake .#laptop

# Desktop
home-manager switch --flake .#desktop
```

Daily updates run via topgrade (`nix flake update` in this repo, then
`home-manager switch --flake ~/dotfiles#laptop`).

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

## Modifier Layer Pattern

So due to the layers of operation there are 3 layers that conflict that need to play well.

1. Compositior (Niri)
2. Terminal (Ghostty)
3. Editor (Neovim)

To manage my shortcuts while keeping the muslce memory between them their is a leader key that defines each region

- Super (or Mod) Is for the Compositor
- Alt Is for the Terminal
- Leader (Space) for Nvim
- Ctrl for Neovim Shell with tabs etc
