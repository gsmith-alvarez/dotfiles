# Shared per-host glue: symlinks the host's niri outputs file into the
# niri config dir. ~/.config/niri is a single out-of-store symlink to
# ~/dotfiles/configs/niri, so the included "outputs.kdl" must live inside
# that directory — hence this activation hook instead of xdg.configFile.
{ host }:
{
  config,
  lib,
  ...
}:
{
  home.activation.linkNiriOutputs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn "$HOME/dotfiles/hosts/${host}/niri-outputs.kdl" "$HOME/.config/niri/outputs.kdl"
  '';
}
