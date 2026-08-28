# cargo2nix: build Rust packages from a generated Cargo.nix file lock.
#
# Attempted conversion of fsel (github:Mjoyufull/fsel). Conclusion:
# cargo2nix requires a Cargo.nix checked into the crate repo (it cannot
# generate one from just a Cargo.lock at build time). fsel does not ship
# one, so converting it would mean vendoring the whole crate + generating
# Cargo.nix ourselves for a crate we don't maintain — rustPlatform.
# buildRustPackage (packages/cargo.nix) already builds it correctly and
# more simply. cargo2nix wiring is kept here for first-party Rust
# workspaces (e.g. your own projects with `nix run github:cargo2nix/cargo2nix`).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # No packages produced yet — wiring is in place for when a first-party
  # Rust workspace (with generated Cargo.nix) lands in this repo.
  #
  # Example for a future first-party workspace:
  #   home.packages = [
  #     ((import inputs.cargo2nix { }).rustPkgs pkgs).workspace.fsel { }
  #   ];
}
