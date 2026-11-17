{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  hostDir = "${config.home.homeDirectory}/dotfiles/hosts/wolfgang";
in
{
  xdg.configFile = {
    "niri/host.kdl".source = mkOutOfStoreSymlink "${hostDir}/niri.kdl";
    "noctalia/wolfgang.toml".source = mkOutOfStoreSymlink "${hostDir}/noctalia.toml";
  };
}
