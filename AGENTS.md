# Dotfiles Repository Guidelines

## Core Philosophy
- **Lean & Native First**: Keep application configurations in their native formats (`.lua`, `.kdl`, `.fish`, `.toml`) under `configs/` and `hosts/<host>/` using out-of-store live symlinks (`home/dotfiles.nix` and `home/hosts/<host>.nix`). Avoid heavy Nix DSL wrappers (`nixvim`, `stylix`, `flake-parts`) that add abstraction layers or require Nix rebuilds for config tweaks.

## Repository Architecture & Module Boundaries
- **Schema & Privilege Separation**:
  - `hosts/<host>/` and `modules/` contain **NixOS (`root`)** modules only. Never place a shared `common_configuration.nix` in `hosts/`; `hosts/` only contains machine directories (`wolfgang/`, `easley/`), while all shared system configuration lives in `modules/core/`.
  - `home/` contains **Home Manager (`giovanni`)** modules only. Keep per-host Home Manager overrides in `home/hosts/<host>.nix` rather than mixing Home Manager and NixOS modules inside `hosts/<host>/`.
  - `lib/` contains pure, schema-free Nix functions and constants (`out-of-store.nix`, `caches.nix`), never NixOS or Home Manager modules.
- **Flat Category Lists vs. Dedicated Modules**:
  - `home/packages/{applications,development,shell,tools}.nix`, `modules/core/programs.nix`, and `modules/core/services.nix` must remain flat, scannable lists of packages and 1–3 line service/program toggles.
  - Whenever a user application or system service requires custom derivations, patches, wrapper scripts, or multi-line configuration/topologies, extract it into its own dedicated file (`home/programs/<app>.nix` for user apps like `anki.nix`, `firefox.nix`, `pele.nix`, `ssh.nix`, `yazi.nix`; `modules/core/<service>.nix` for system services like `syncthing.nix`, `secrets.nix`, `system.nix`).
  - Place general `nixpkgs.overlays` in `modules/core/packages.nix`, keeping only desktop-specific package wrappers (`noctalia`, `wayscriber`) co-located in `modules/desktop/default.nix`.
- **Barrel Imports (`default.nix`)**: Use `default.nix` for directory barrel files (`modules/core/default.nix`, `home/packages/default.nix`, `home/programs/default.nix`) so parent modules can import directories by path (`./packages`, `./programs`, `../../modules/core`).

## Git & Testing Workflow
- **Test Before Commit/Push**: Never run `git commit` or `git push` automatically after fixing an issue or implementing a feature. Apply the changes, run verification (`nix fmt .`, `nix flake check -L`, `niri validate`, `noctalia config validate`), and wait for the user to test and explicitly request a commit/push. Always pass `.` to `nix fmt .` so `nixfmt` does not wait on `stdin`.

## Out-of-Store Symlink Boundaries
- **Ownership Contract**: Never overlap a live out-of-store directory symlink with individual Home Manager-generated files in the same directory.
- **Directory-to-File Symlink Migrations**: When splitting an existing directory symlink (`~/.config/<app>`) into per-file symlinks (`~/.config/<app>/<file>`), always add a `home.activation` step with `lib.hm.dag.entryBefore [ "checkLinkTargets" ]` that removes `[ -L ~/.config/<app> ]` first so Home Manager does not follow the old directory symlink into `~/dotfiles/configs/<app>/` and create circular symlinks.
