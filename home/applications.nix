{ pkgs, ... }:
let
  sources = pkgs.callPackage ../_sources/generated.nix { };
  zoteroProfile = "wr8e44xv.default";
  tailtui = pkgs.stdenvNoCC.mkDerivation {
    pname = "tailtui";
    inherit (sources.tailtui) version src;
    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      install -Dm755 tailtui $out/bin/tailtui
      runHook postInstall
    '';
  };
in
{
  home.packages = with pkgs; [
    tailtui
    # Desktop applications
    easyeffects
    pkgs.wayscriber
    obsidian
    openbot
    playerctl
    spotify-player
    wl-clipboard
    libreoffice
    ghostty
    bitwarden-desktop
    zotero
    obs-studio
    vlc

    # Fonts
    jetbrains-mono
    monaspace
  ];

  home.file.".zotero/zotero/${zoteroProfile}/extensions/better-bibtex@iris-advies.com.xpi".source =
    sources.better-bibtex.src;
  services.flatpak.packages = [
    "com.super_productivity.SuperProductivity"
  ];
}
