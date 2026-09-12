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
    # NetworkManager manages wifi through its default wpa_supplicant backend
    networkmanager.enable = true;
  };

  # Bootloader
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Load exfat at boot so USBs can be mounted
    kernelModules = [ "exfat" ];
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

  # Bluetooth
  hardware.bluetooth.enable = true;

  # State version
  system.stateVersion = "26.05";

  # Lix Package Manager
  # nix.package = pkgs.lixPackageSets.stable.lix;
}
