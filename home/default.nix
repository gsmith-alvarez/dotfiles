{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./dotfiles.nix
    ./shell.nix
    ./yazi.nix
    ./appearance.nix
    ./stats.nix
    ./anki.nix
    ./development.nix
    ./tools.nix
    ./applications.nix
  ];

  news.display = "show";

  programs.home-manager.enable = true;

  home = {
    username = "giovanni";
    homeDirectory = "/home/giovanni";
    # Pins Home Manager state conventions; do not change across release updates.
    stateVersion = "26.05";
  };
}
