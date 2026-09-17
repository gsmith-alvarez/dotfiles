{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Desktop applications
    cliphist
    easyeffects
    ghostty
    keepassxc
    playerctl
    spotify-player
    wl-clipboard

    # Fonts
    jetbrains-mono
    monaspace
  ];

  services.flatpak.packages = [
    "md.obsidian.Obsidian"
    "app.zen_browser.zen"
    "com.super_productivity.SuperProductivity"
  ];
}
