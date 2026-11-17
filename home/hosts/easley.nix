{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  hostDir = "${config.home.homeDirectory}/dotfiles/hosts/easley";
in
{
  xdg.configFile = {
    "niri/host.kdl".source = mkOutOfStoreSymlink "${hostDir}/niri.kdl";
    "noctalia/easley.toml".source = mkOutOfStoreSymlink "${hostDir}/noctalia.toml";
  };
}
