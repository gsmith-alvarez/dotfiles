{
  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  hostDir = "${config.home.homeDirectory}/dotfiles/hosts/easley";
in
{
  imports = [ ../programs/cad.nix ];

  home.packages = with pkgs; [
    # Audio production
    bitwig-studio
  ];

  xdg.configFile = {
    "niri/host.kdl".source = mkOutOfStoreSymlink "${hostDir}/niri.kdl";
    "noctalia/easley.toml".source = mkOutOfStoreSymlink "${hostDir}/noctalia.toml";
  };
}
