{
  inputs,
  ...
}:
{
  nixpkgs.config = {
    allowUnfree = true;
    # Required by dependencies (e.g. Obsidian/Vesktop) until upstream packages update runtime.
    permittedInsecurePackages = [
      "electron-41.10.6"
      # Zotero's Nixpkgs package currently embeds end-of-life Firefox ESR 140.
      "firefox-esr-140-bin-unwrapped-140.17.0esr"
      # Required by kicadAddons.kikit for local PCB template rendering until upstream drops pybars3.
      "python3.14-pybars3-0.9.7"
    ];
  };

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];
}
