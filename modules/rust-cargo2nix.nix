# cargo2nix: build Rust workspaces from a generated Cargo.nix file lock.
#
# KEPT AS STANDING INFRASTRUCTURE for first-party Rust projects.
#
# From the fsel attempt (see git history 8da40e6): cargo2nix requires a
# Cargo.nix committed to the crate repo — it cannot generate one from just
# a Cargo.lock at build time. Third-party crates without one (like fsel)
# are better served by rustPlatform.buildRustPackage (packages/cargo.nix),
# which builds the same thing from cargoHash directly.
#
# To activate for a first-party workspace:
#   1. Generate the lock file in your crate repo:
#        nix run github:cargo2nix/cargo2nix -- /path/to/your/crate
#   2. Commit the resulting Cargo.nix to that repo.
#   3. Build here, e.g. via a flake input for the crate +:
#        ((import inputs.cargo2nix { inherit pkgs; }).rustPkgs pkgs)
#          .workspace.<crateName> { }
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # No cargo2nix packages produced yet — fsel (the only Rust build) uses
  # buildRustPackage in packages/cargo.nix, which is the right tool for
  # third-party crates. Wiring activates when a first-party workspace
  # with a committed Cargo.nix lands.
}
