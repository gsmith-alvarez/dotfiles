{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common_configuration.nix
    ../../modules/core
    ../../modules/desktop
  ];

  # Easley has its own wallpaper and desktop output layout; Wolfgang keeps the shared defaults.
  services = {
    displayManager.noctalia-greeter.settings = {
      appearance.wallpaper = {
        path = "/home/giovanni/Pictures/wallpapers/neptune.png";
        fill_mode = "crop";
      };
      output = {
        use_synced_settings = false;
        layout = "DP-2:0,0; DP-1:2560,0";
      };
    };
    resolved.enable = true;
  };

  home-manager.users.giovanni = {
    imports = [ ../../home/hosts/easley.nix ];
  };

  networking.hostName = "easley";

  # Bootloader
  boot.loader.systemd-boot.extraEntries."windows.conf" = ''
    title Windows
    efi /EFI/Microsoft/Boot/bootmgfw.efi
    sort-key z_windows
  '';
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  # Gaming
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  environment.systemPackages = [ pkgs.mangohud ];
  zramSwap.enable = true;

  hardware = {
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

}
