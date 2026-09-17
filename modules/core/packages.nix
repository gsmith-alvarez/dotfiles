{ inputs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
    # Required by dependencies (e.g. Obsidian/Vesktop) until upstream packages update runtime.
    permittedInsecurePackages = [
      "electron-41.10.6"
    ];
  };

  # Applied at system level; propagates across both system and Home Manager via useGlobalPkgs.
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];
}
