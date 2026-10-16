{
  inputs,
  ...
}: {
  nixpkgs.config = {
    allowUnfree = true;
    # Required by dependencies (e.g. Obsidian/Vesktop) until upstream packages update runtime.
    permittedInsecurePackages = [
      "electron-41.10.6"
    ];
  };

  # Nightly Neovim (config uses scrolloffpad + TextPutPost, nightly-only)
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];
}
