{ pkgs, config, ... }:

{
  home.username = "giovanni";
  home.homeDirectory = "/home/giovanni";
  home.stateVersion = "26.05";

  imports = [
    ./home/editor.nix
    ./home/git.nix
    ./home/terminal.nix
    ./home/agents.nix
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.local/share/mise/shims"
    "${config.home.homeDirectory}/.bun/bin"
  ];

  home.packages = with pkgs; [
    nh
    nix-search-cli
    direnv
    nix-direnv
    flake-checker
    flake-edit
  ];

  programs.home-manager.enable = true;
}
