# Niri Setup Notes

This file contains operational guidance only. The Nix flake and linked configuration files are the source of truth for host state; do not copy current monitor, workspace, wallpaper, package, or theme values into this document.

## Source of truth

- `hosts/<host>/default.nix` — host-specific NixOS settings and activation overrides
- `modules/` — shared NixOS modules
- `home/` — Home Manager packages and link declarations
- `configs/niri/config.kdl` — Niri compositor configuration
- `configs/noctalia/config.toml` — shared Noctalia configuration
- `hosts/<host>/noctalia.toml` — host-specific Noctalia overrides
- `configs/wayscriber/config.toml` — Wayscriber configuration
- `configs/easy-effects/` — EasyEffects presets

Noctalia host overlays are linked by the host's Home Manager activation. Keep per-host values there instead of modifying the shared Noctalia file for one machine.

## Activation and validation

Preview a host rebuild:

```sh
nixos-rebuild dry-build --flake ~/dotfiles#<host>
```

Activate a host:

```sh
nh os switch .#<host>
```

The two configured host names are `wolfgang` and `easley`.

Validate the changed desktop configuration:

```sh
niri validate -c ~/.config/niri/config.kdl
noctalia config validate
```

After changing Niri settings, reload the compositor configuration with:

```sh
niri msg action load-config-file
```

After changing Noctalia settings, request a shell reload with:

```sh
noctalia msg config-reload
```

Greeter display, wallpaper, and other system settings apply through the host switch and are used on the next greeter start. Restart greetd only when needed:

```sh
sudo systemctl restart greetd
```

## Configuration ownership

Home Manager uses out-of-store links for user configuration, so edits to linked application files are visible immediately when the application supports reloads. Package, module, host, and greeter changes still require a Nix activation.

Noctalia has two layers:

- `~/.config/noctalia/*.toml` — curated configuration managed by this repository
- `~/.local/state/noctalia/settings.toml` — app-managed GUI overrides, loaded last

Do not add the Noctalia state file to the repository. If a GUI override masks a curated value, inspect or remove the state override before debugging the curated configuration.

## Keybindings and runtime behavior

The authoritative Niri bindings are in the `binds {}` block of `configs/niri/config.kdl`. Noctalia actions are invoked through `noctalia msg`; inspect the Niri config rather than maintaining a second keybinding list here.

Niri startup commands, window rules, output layout, workspace placement, and display modes are all declared in `configs/niri/config.kdl`.

Package and service ownership is declared in `home/` and `modules/`; do not document installed package snapshots here.
