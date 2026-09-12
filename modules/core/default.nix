{
  pkgs,
  inputs,
  ...
}:

{
  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "giovanni" ];
    accept-flake-config = true;
    keep-outputs = true;
    http-connections = 50;
    extra-substituters = [
      "https://cache.numtide.com"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-41.10.6"
    ];
  };

  # Neovim nightly overlay
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  # Programs
  programs = {
    nh = {
      enable = true;
      clean = {
        extraArgs = "--keep 10";
        dates = "weekly";
      };
      flake = "/home/giovanni/dotfiles";
    };
    nix-ld.enable = true;
    command-not-found.enable = false;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    thunderbird.enable = true;
  };

  # Time & Locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Sound
  security.rtkit.enable = true;

  # Services
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
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

  # User accounts
  users.users.giovanni = {
    isNormalUser = true;
    description = "giovanni";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      zed-editor
      nautilus
      wayscriber
    ];
    shell = pkgs.fish;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vesktop
    xwayland-satellite
    pciutils
    usbutils
    smartmontools
    gptfdisk
    lsof
    psmisc
    ethtool
    tcpdump
    networkmanagerapplet
  ];
}
