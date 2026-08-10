{ config, ... }:

{
  home.username = "giovanni";
  home.homeDirectory = "/home/giovanni";
  home.stateVersion = "26.05";

  imports = [
    ./home/editor.nix
    ./home/git.nix
    ./home/terminal.nix
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.local/share/mise/shims"
    "${config.home.homeDirectory}/.bun/bin"
  ];

  programs.home-manager.enable = true;
}
