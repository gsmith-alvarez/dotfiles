{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common_configuration.nix
    ../../modules/core
    ../../modules/desktop
  ];

  services.displayManager.noctalia-greeter.settings.appearance.wallpaper = {
    path = "/home/giovanni/Pictures/Wallpapers/glitch.jpg";
    fill_mode = "crop";
  };

  home-manager.users.giovanni = {
    imports = [ ../../home/hosts/wolfgang.nix ];
  };

  networking.hostName = "wolfgang";
}
