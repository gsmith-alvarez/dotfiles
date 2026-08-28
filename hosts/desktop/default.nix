# Desktop host module (spec taken from the development branch:
# DP-3 primary at x=0 + HDMI-A-1 at x=1920, study/utils workspaces).
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
    ln -sfn "$HOME/dotfiles/hosts/desktop/niri-outputs.kdl" "$HOME/.config/niri/outputs.kdl"
  '';
}
