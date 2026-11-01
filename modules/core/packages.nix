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
    ];
  };

  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];
}
