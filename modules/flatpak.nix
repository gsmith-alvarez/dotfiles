# Declarative Flatpak management via nix-flatpak (HM service).
# The app list mirrors what scripts/init.sh used to install imperatively;
# init.sh's flatpak section is now redundant for machines deploying this flake.
#
# NOTE: `update.onActivation = true` runs `flatpak update` for managed apps on
# every `home-manager switch`. Set to false if you prefer manual updates.
{
  inputs,
  ...
}:

{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  services.flatpak = {
    enable = true;

    # remotes defaults to Flathub; declared explicitly for clarity
    remotes = [ { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; } ];

    update.onActivation = true;

    packages = [
      "org.blender.Blender"          # 3D
      "com.calibre_ebook.calibre"    # ebooks
      "it.mijorus.gearlever"         # appimage manager
      "org.keepassxc.KeePassXC"      # secrets
      "org.kde.krita"                # painting
      "org.kde.kdenlive"             # video
      "com.obsproject.Studio"        # streaming/recording
      "org.qbittorrent.qBittorrent"
      "com.github.tchx84.Flatseal"
      "org.freecad.FreeCAD"
    ];
  };
}
