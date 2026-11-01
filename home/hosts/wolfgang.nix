{ config, ... }:
{
  xdg.configFile."noctalia/wolfgang.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/home/giovanni/dotfiles/hosts/wolfgang/noctalia.toml";
}
