{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/desktop
  ];

  # Hostname & Networking
  networking = {
    hostName = "wolfgang";
    wireless.enable = true;
    networkmanager = {
      enable = true;
      # wifi.backend = "iwd";
    };
  };

  # Bootloader
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
  };
  # Graphics
  hardware.graphics.enable32Bit = true;

  # State version
  system.stateVersion = "26.05";

  # Lix Package Manager
  # nix.package = pkgs.lixPackageSets.stable.lix;
}
