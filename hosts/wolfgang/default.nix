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
    networkmanager.dns = "systemd-resolved";
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };

  services.resolved.enable = true;

  # Bootloader
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Load exfat at boot so USBs can be mounted
    kernelModules = [ "exfat" ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        bootCounting.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    binfmt = {
      emulatedSystems = [ "riscv64-linux" ];
    };
  };
  # Graphics
  hardware.graphics.enable32Bit = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Pins compatibility defaults for stateful data and migrations; do not bump on system updates.
  system.stateVersion = "26.05";
}
