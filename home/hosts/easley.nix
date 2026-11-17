{ config, ... }:
{
  xdg.configFile."noctalia/easley.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hosts/easley/noctalia.toml";
}
