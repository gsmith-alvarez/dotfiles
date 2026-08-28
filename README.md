# Dotfiles

Personal Fedora configuration. Runs niri with DMS, themed with Catppuccin Mocha, and managed by a Home Manager flake that lives in this repo.

## Stack

- Desktop: [niri](https://github.com/YaLTeR/niri) + [DMS](https://github.com/AvengeMedia/DankMaterialShell)
- Shell: [Fish](https://fishshell.com/)
- Terminal: [Ghostty](https://ghostty.org/)
- Prompt: [Starship](https://starship.rs/)
- Config management: Home Manager flake, this repo is the source of truth
- System provisioner: [scripts/init.sh](scripts/init.sh) for DNF/Flatpak packages and systemd services

## Structure

```
dotfiles/
├── flake.nix            # HM entry point, homeConfigurations.laptop / .desktop
├── hosts/               # Machine-specific HM modules + niri outputs
│   ├── laptop/          #   eDP-1 (built-in panel)
│   └── desktop/         #   DP-3 + HDMI-A-1, study/utils workspaces
├── modules/             # Shared HM modules (editor, git, terminal, services, agents)
├── packages/            # Custom Nix packages / overlay
├── configs/             # Native config files, flat, no stow nesting
│   ├── fish/  nvim/  niri/  ghostty/  yazi/  ...
│   └── ...
└── scripts/             # init.sh provisioner, cleanup.sh
```

Configs stay in their native formats (.kdl, .lua, .toml) and Home Manager
symlinks them out of the Nix store. Edit a file in `configs/` and the change
applies live, no `home-manager switch` needed.

Machine-specific niri settings (outputs, workspaces) live in
`hosts/<host>/niri-outputs.kdl`. The shared `configs/niri/config.kdl` ends
with `include "outputs.kdl"`, and since that include comes last it wins over
the DMS-generated includes.

## Deploying

```bash
home-manager switch --flake .#laptop
home-manager switch --flake .#desktop
```

Daily updates run through topgrade, which runs `nix flake update` in this
repo and then `home-manager switch --flake ~/dotfiles#laptop`.

## Highlights

### fnav (fish navigation)
Fuzzy directory navigator built on [fd](https://github.com/sharkdp/fd),
[fzf](https://github.com/junegunn/fzf),
[zoxide](https://github.com/ajeetdsouza/zoxide), and
[eza](https://github.com/eza-community/eza).

- `fnav` / `d`: fuzzy search subdirectories
- `fnav up` / `u`: fuzzy search parent directories
- `fnav zoxide` / `z`: fuzzy search the zoxide database
- Shows eza tree previews, toggles hidden files

### Yazi file manager
[Yazi](https://github.com/sxyazi/yazi) with plugins: [ouch](https://github.com/pypa/ouch) for archive preview and extraction, `git` for live status in the sidebar, plus `smart-filter`, `chmod`, `mount`, and `jump-to-char`.

### Development
[Mise](https://mise.jdx.dev/) manages Node, Bun, and Zig runtimes plus LSPs.
[Neovim](https://neovim.io/) runs nightly builds with a custom runner system
and blink.cmp, snacks.nvim, dropbar.nvim, mini.nvim. Containers are Podman
and Distrobox. Clipboard is wl-clipboard with cliphist.

### System and audio
OpenTabletDriver and wayscriber for the graphics tablet. spotify-player for
music from the terminal, Easy Effects for the Shure SM7B chain.

## Fish abbreviations

| Abbr | Command | Description |
| :--- | :--- | :--- |
| `v` | `nvim` | Edit with Neovim |
| `ls` | `eza ...` | List files with eza |
| `rg` | `batgrep` | Search text with bat-extras |
| `cat` | `bat` | View file with bat |
| `find` | `fd` | Find files with fd |
| `ch` | cliphist selector | View clipboard history |
| `copy` | `wl-copy` | Copy to clipboard |
| `paste` | `wl-paste` | Paste from clipboard |
| `u`/`d`/`z` | `fnav ...` | Navigate directories |

## Modifier layer pattern

Three layers of shortcuts have to coexist without stealing chords from each
other: the compositor (niri), the terminal (Ghostty), and the editor
(Neovim). Each layer owns one modifier, so muscle memory transfers between
them.

- Super (Mod) belongs to the compositor
- Alt belongs to the terminal
- Leader (Space) belongs to nvim
- Ctrl covers the nvim shell, tabs, and similar
