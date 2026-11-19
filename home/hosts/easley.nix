{
  config,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  hostDir = "${config.home.homeDirectory}/dotfiles/hosts/easley";
in
{
  imports = [
    ../programs/bitwig.nix
    ../programs/cad.nix
  ];

  xdg.configFile = {
    "niri/host.kdl".source = mkOutOfStoreSymlink "${hostDir}/niri.kdl";
    "noctalia/easley.toml".source = mkOutOfStoreSymlink "${hostDir}/noctalia.toml";
  };
}
