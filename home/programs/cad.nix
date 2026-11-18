{ pkgs, ... }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };

  freecadCatppuccinHook = pkgs.writeShellScript "freecad-catppuccin-hook" ''
    data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/FreeCAD"
    mkdir -p "$data_dir/Mod" "$data_dir/Gui/Stylesheets/overlay"
    ln -sfn "${sources.freecad-catppuccin.src}" "$data_dir/Mod/CatppuccinTheme"
    ln -sfn "${sources.freecad-catppuccin.src}/CatppuccinNights/CatppuccinNights.qss" \
      "$data_dir/Gui/Stylesheets/CatppuccinNights.qss"
    ln -sfn "${sources.freecad-catppuccin.src}/CatppuccinNights/overlay/CatppuccinNights_Overlay.qss" \
      "$data_dir/Gui/Stylesheets/overlay/CatppuccinNights_Overlay.qss"
  '';

  freecadWithPlugins = pkgs.freecad.customize {
    modules = [
      sources.freecad-fasteners.src
      sources.freecad-sheetmetal.src
      sources.freecad-curves.src
      sources.freecad-gears.src
      sources.freecad-kicadstepup.src
      sources.freecad-lattice2.src
      sources.freecad-catppuccin.src
    ];
    userCfg = "${sources.freecad-catppuccin.src}/CatppuccinNights/CatppuccinNights.cfg";
    makeWrapperFlags = [
      "--run"
      "${freecadCatppuccinHook}"
    ];
  };

  mkPcmAddon =
    name: src:
    pkgs.lib.makeOverridable (
      {
        addonPath ? "addon.zip",
        ...
      }:
      pkgs.runCommand "kicadaddon-${name}" { } ''
        mkdir -p "$out"
        ln -s ${src} "$out/${addonPath}"
      ''
    ) { };

  kicadBase = pkgs.kicad.override {
    addons = [
      pkgs.kicadAddons.kikit
      pkgs.kicadAddons.kikit-library
      (mkPcmAddon "interactive-html-bom" sources.kicad-ibom.src)
      (mkPcmAddon "jlc-fabrication-toolkit" sources.kicad-jlc-plugin.src)
      (mkPcmAddon "board2pdf" sources.kicad-board2pdf.src)
    ];
  };

  kicadCatppuccinHook = pkgs.writeShellScript "kicad-catppuccin-hook" ''
    colors_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/kicad/10.0/colors"
    mkdir -p "$colors_dir"
    for f in "${sources.catppuccin-kicad.src}"/colors/*.json; do
      ln -sfn "$f" "$colors_dir/$(basename "$f")"
    done
  '';

  kicadWithPlugins = pkgs.symlinkJoin {
    name = "${kicadBase.name}-with-themes";
    paths = [ kicadBase ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for exe in kicad pcbnew eeschema; do
        if [ -e "$out/bin/$exe" ] && [ -L "$out/bin/$exe" ]; then
          target="$(readlink -f "$out/bin/$exe")"
          rm "$out/bin/$exe"
          makeWrapper "$target" "$out/bin/$exe" --run "${kicadCatppuccinHook}"
        fi
      done
    '';
    inherit (kicadBase) meta;
  };
in
{
  home.packages = [
    freecadWithPlugins
    kicadWithPlugins
  ];
}
