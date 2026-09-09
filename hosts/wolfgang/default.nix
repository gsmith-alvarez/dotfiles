{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/desktop
  ];

  # Hostname
  networking.hostName = "wolfgang";

  # Networking
  networking.wireless.enable = false;
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Graphics
  hardware.graphics.enable32Bit = true;

  # State version
  system.stateVersion = "26.05";
}
