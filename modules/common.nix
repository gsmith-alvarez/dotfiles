# Shared Home-Manager module — used by every host.
# Native configs live in the repo root (e.g. nvim/.config/nvim) and are
# symlinked out-of-store, so live edits apply without `home-manager switch`.
{
  config,
  pkgs,
  inputs,
  ...
}:

let
  link = rel: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${rel}";
in
{
  imports = [
    ./editor.nix
    ./git.nix
    ./terminal.nix
    ./services.nix
    ./agents.nix
  ];

  home.username = "giovanni";
  home.homeDirectory = "/home/giovanni";
  home.stateVersion = "26.05";

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.bun/bin"
  ];

  xdg.configFile = {
    atuin.source = link "atuin/.config";
    bat.source = link "bat/.config/bat";
    btop.source = link "btop/.config/btop";
    fish.source = link "fish";
    fuzzel.source = link "fuzzel/.config/fuzzel";
    # ghostty — installed from dnf instead of Nix (EGL issue with Nix build).
    # Ghostty config is linked manually: ln -sf ~/dotfiles/ghostty/.config/ghostty ~/.config/ghostty
    #ghostty.source = link "ghostty/.config/ghostty";
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
