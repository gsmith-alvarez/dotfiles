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
    (inputs.zotero-pkg.packages.${pkgs.stdenv.hostPlatform.system}.zotero.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        sed -i "s|^Exec=.*|Exec=$out/bin/zotero --url %u|" $out/share/applications/zotero.desktop
      '';
    }))

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
