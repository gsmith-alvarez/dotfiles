{ config, ... }:

let
  link = rel: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${rel}";
in
{
  xdg.configFile = {
    atuin.source = link "atuin/.config";
    bat.source = link "bat/.config/bat";
    btop.source = link "btop/.config/btop";
    fish.source = link "fish";
    fuzzel.source = link "fuzzel/.config/fuzzel";
    ghostty.source = link "ghostty/.config/ghostty";
    lazygit.source = link "lazygit/.config/lazygit";
    navi.source = link "navi/.config/navi";
    niri.source = link "niri/.config/niri";
    nvim.source = link "nvim";
    "spotify-player".source = link "spotify-player/.config/spotify-player";
    "starship.toml".source = link "starship/.config/starship.toml";
    "topgrade.toml".source = link "topgrade/.config/topgrade.toml";
    yazi.source = link "yazi/.config/yazi";
    "OpenTabletDriver/settings.json".source =
      link "OpenTabletDriver/.config/OpenTabletDriver/settings.json";
  };
  home.file.".bashrc".source = link "bash/.bashrc";
}
