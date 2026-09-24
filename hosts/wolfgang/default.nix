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

  # so resolv.conf doesn't get clobbered on every connect (NM rc-manager=resolvconf).
  environment.etc."NetworkManager/dispatcher.d/99-AirYorkPLUS-dns" = {
    mode = "0755";
    text = ''
      #!/run/current-system/sw/bin/bash
      if [ "$2" != "up" ]; then exit 0; fi
      case "$CONNECTION_ID" in
        *AirYorkPLUS*) ;;
        *) exit 0 ;;
      esac
      cur=$(${pkgs.networkmanager}/bin/nmcli -g ipv4.dns connection show "$CONNECTION_ID" 2>/dev/null)
      if [ "$cur" != "1.1.1.1" ]; then
        ${pkgs.networkmanager}/bin/nmcli connection modify "$CONNECTION_ID" \
          ipv4.dns 1.1.1.1 ipv4.ignore-auto-dns yes
        ${pkgs.networkmanager}/bin/nmcli device reapply "$1"
      fi
    '';
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
