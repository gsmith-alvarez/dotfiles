{ config, ... }:
{
  xdg.configFile."noctalia/wolfgang.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hosts/wolfgang/noctalia.toml";
}
