# Shared Home-Manager module — used by every host.
# Native configs live in configs/ (flat, no stow nesting) and are
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
    ./flatpak.nix
    ./python-uv.nix
    ./rust-cargo2nix.nix
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
    atuin.source = link "configs/atuin";
    bat.source = link "configs/bat";
    btop.source = link "configs/btop";
    fish.source = link "configs/fish";
    fuzzel.source = link "configs/fuzzel";
    # ghostty — installed from dnf instead of Nix (EGL issue with Nix build),
    # but its config is still managed here out-of-store.
    ghostty.source = link "configs/ghostty";
    lazygit.source = link "configs/lazygit";
    navi.source = link "configs/navi";
    niri.source = link "configs/niri";
    nvim.source = link "configs/nvim";
    "spotify-player".source = link "configs/spotify-player";
    "starship.toml".source = link "configs/starship/starship.toml";
    "topgrade.toml".source = link "configs/topgrade/topgrade.toml";
    yazi.source = link "configs/yazi";
    "OpenTabletDriver/settings.json".source =
      link "configs/OpenTabletDriver/settings.json";
  };
  home.file.".bashrc".source = link "configs/bash/bashrc";

  # easy-effects presets (Shure SM7B mic chain etc.) target the app data dir
  xdg.dataFile."easyeffects/output/easyeffectpreset.json".source =
    link "configs/easy-effects/easyeffectpreset.json";
  xdg.dataFile."easyeffects/input/Shure SM7B.json".source =
    link "configs/easy-effects/Shure SM7B.json";
}
