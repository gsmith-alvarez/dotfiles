{
  services = {
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
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "giovanni";
      dataDir = "/home/giovanni/Documents/Obsidian";
      configDir = "/home/giovanni/.config/syncthing";
    };
    # auto-mount USB drives / expose to file managers
    udisks2.enable = true;
    gvfs.enable = true;
    flatpak.enable = true;
    openssh.enable = true;
    tailscale.enable = true;
    fwupd.enable = true;
  };
}
