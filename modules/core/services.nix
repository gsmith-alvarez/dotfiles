{ pkgs, ... }:

{
  services = {
    resolved.enable = true;
    gnome.gnome-keyring.enable = true;
    udev.packages = [ pkgs.openocd ];
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
    fstrim.enable = true;
    printing.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    libinput.enable = true;
    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };
    };
    # auto-mount USB drives / expose to file managers
    udisks2.enable = true;
    gvfs.enable = true;
    flatpak.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    fwupd.enable = true;
    scx-loader = {
      enable = true;
      config = {
        default_sched = "scx_bpfland";
      };
    };
  };

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
