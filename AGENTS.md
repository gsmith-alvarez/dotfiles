# Dotfiles Repository Guidelines

## Core Philosophy
- **Lean & Native First**: Keep application configurations in their native formats (`.lua`, `.kdl`, `.fish`, `.toml`) under `configs/` and `hosts/<host>/` using out-of-store live symlinks (`home/dotfiles.nix` and `home/hosts/<host>.nix`). Avoid heavy Nix DSL wrappers (`nixvim`, `stylix`, `flake-parts`) that add abstraction layers or require Nix rebuilds for config tweaks.

## Git & Testing Workflow
- **Test Before Commit/Push**: Never run `git commit` or `git push` automatically after fixing an issue or implementing a feature. Apply the changes, run verification (`nix flake check -L`, `niri validate`, `noctalia config validate`), and wait for the user to test and explicitly request a commit/push.

## Out-of-Store Symlink Boundaries
- **Ownership Contract**: Never overlap a live out-of-store directory symlink with individual Home Manager-generated files in the same directory.
- **Directory-to-File Symlink Migrations**: When splitting an existing directory symlink (`~/.config/<app>`) into per-file symlinks (`~/.config/<app>/<file>`), always add a `home.activation` step with `lib.hm.dag.entryBefore [ "checkLinkTargets" ]` that removes `[ -L ~/.config/<app> ]` first so Home Manager does not follow the old directory symlink into `~/dotfiles/configs/<app>/` and create circular symlinks.
