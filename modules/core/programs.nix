{ pkgs, ... }:
{
  programs = {
    nh = {
      enable = true;
      clean = {
        extraArgs = "--keep 5";
        dates = "weekly";
      };
      flake = "/home/giovanni/dotfiles";
    };
    nix-ld.enable = true;
    command-not-found.enable = false;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    thunderbird.enable = true;
    appimage.enable = true;
    appimage.binfmt = true;
    compsize.enable = true;
    btrfs-heatmap.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vesktop
    xwayland-satellite
    pciutils
    usbutils
    smartmontools
    gptfdisk
    lsof
    psmisc
    ethtool
    tcpdump

    # Compatibility shim: routes Snacks.picker.cliphist() in Neovim to stash-clipboard
    (writeShellScriptBin "cliphist" ''
      exec ${stash-clipboard}/bin/stash "$@"
    '')

    # Full cross-toolchain: as, ld, gcc, objdump, nm, readelf
    pkgsCross.riscv64.buildPackages.gcc
    # Multi-architecture debugger (supports connecting to QEMU gdbserver)
    gdb
    # User-space emulator (provides qemu-riscv64)
    qemu
  ];
}
