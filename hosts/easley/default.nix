{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/desktop
  ];

  # Easley has its own wallpaper and desktop output layout; Wolfgang keeps the shared defaults.
  services.displayManager.noctalia-greeter.settings = {
    appearance.wallpaper = {
      path = "/home/giovanni/Pictures/wallpapers/neptune.png";
      fill_mode = "crop";
    };
    output = {
      use_synced_settings = false;
      layout = "DP-2:0,0; DP-1:2560,0";
    };
  };

  home-manager.users.giovanni = {
    imports = [ ../../home/hosts/easley.nix ];
  };

  # Hostname & Networking
  networking = {
    hostName = "easley";
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
        extraEntries."windows.conf" = ''
          title Windows
          efi /EFI/Microsoft/Boot/bootmgfw.efi
          sort-key z_windows
        '';
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
