{ pkgs, inputs, ... }:
let
  sources = pkgs.callPackage ../_sources/generated.nix { };
  zoteroProfile = "wr8e44xv.default";
in
{
  home.packages = with pkgs; [
    # Desktop applications
    easyeffects
    ghostty
    keepassxc
    playerctl
    spotify-player
    wl-clipboard
    libreoffice
    koreader
    gnome-calculator
    inputs.zotero-pkg.packages.${pkgs.stdenv.hostPlatform.system}.zotero

    # Fonts
    jetbrains-mono
    monaspace
  ];

  home.file.".zotero/zotero/${zoteroProfile}/extensions/better-bibtex@iris-advies.com.xpi".source =
    sources.better-bibtex.src;
  services.flatpak.packages = [
    "md.obsidian.Obsidian"
    "app.zen_browser.zen"
    "com.super_productivity.SuperProductivity"
  ];
}
