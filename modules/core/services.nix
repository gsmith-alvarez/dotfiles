{
  services = {
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
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "giovanni";
      dataDir = "/home/giovanni/Documents";
      configDir = "/home/giovanni/.config/syncthing";
      settings = {
        devices = {
          wolfgang.id = "AT77Z27-FGPEYAL-JVFCXNC-WF5HOZH-4TSR5DJ-J77LAD6-OUANG26-TK4U7QJ";
          Socialism.id = "GQ4Y26P-7QONPQA-OBJX3ZZ-BTSTNYS-G3432ES-DEY3KDP-ZYDVHME-WD54NAE";
          easley.id = "5XVG5YY-IBWL6HA-SO75OR4-ZKF43FM-Z4J5OVR-Y7YBR65-DCD3BPC-EDEHIQE";
        };
        folders = {
          Obsidian = {
            id = "Obsidian";
            label = "Obsidian";
            path = "/home/giovanni/Documents/Obsidian";
            devices = [
              "wolfgang"
              "Socialism"
              "easley"
            ];
          };
          Projects = {
            id = "Projects";
            label = "Projects";
            path = "/home/giovanni/Documents/Projects";
            devices = [
              "wolfgang"
              "Socialism"
              "easley"
            ];
          };
          School = {
            id = "School";
            label = "School";
            path = "/home/giovanni/Documents/School";
            devices = [
              "wolfgang"
              "Socialism"
              "easley"
            ];
          };
          WorkDocuments = {
            id = "WorkDocuments";
            label = "WorkDocuments";
            path = "/home/giovanni/Documents/WorkDocuments";
            devices = [
              "wolfgang"
              "Socialism"
              "easley"
            ];
          };
          Textbooks = {
            id = "chlyf-z2vyh";
            label = "Textbooks";
            path = "/home/giovanni/Documents/Textbooks";
            devices = [
              "wolfgang"
              "Socialism"
              "easley"
            ];
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
}
