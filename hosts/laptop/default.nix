# Laptop host module (hostname: fedora — single built-in eDP-1 panel).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Shared base configs (out-of-store symlinks → live editing)
  # are provided by modules/common.nix.

  # Host-specific niri outputs/workspaces. ~/.config/niri is a single
  # out-of-store symlink to ~/dotfiles/niri/.config/niri, so the included
  # "outputs.kdl" must live inside that directory — symlink it per host.
  home.activation.linkNiriOutputs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn "$HOME/dotfiles/hosts/laptop/niri-outputs.kdl" "$HOME/.config/niri/outputs.kdl"
  '';
}
