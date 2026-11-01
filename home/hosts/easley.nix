{ pkgs, config, ... }:
{
  home.packages = [ pkgs.steam ];

  xdg.configFile."noctalia/easley.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/home/giovanni/dotfiles/hosts/easley/noctalia.toml";
}
