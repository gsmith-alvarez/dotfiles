{ config, pkgs, inputs, ... }:

{
  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "giovanni" ];
    accept-flake-config = true;
    extra-substituters = [
      "https://cache.numtide.com"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Neovim nightly overlay
  nixpkgs.overlays = [
    inputs.neovim-nightly-overlay.overlays.default
  ];

  # nh CLI helper
  programs.nh = {
    enable = true;
    clean = {
      extraArgs = "--keep 10";
      dates = "weekly";
    };
    flake = "/home/giovanni/dotfiles";
  };

  # Core environment & programs
  programs.nix-ld.enable = true;
  programs.command-not-found.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fish.enable = true;

  # Time & Locale
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Power management
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Input & Keyboard remapping
  services.libinput.enable = true;
  services.keyd = {
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
    ];
    shell = pkgs.fish;
  };

  # Services
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "giovanni";
    dataDir = "/home/giovanni/Documents/Obsidian";
    configDir = "/home/giovanni/.config/syncthing";
  };

  services.flatpak.enable = true;
  services.openssh.enable = true;

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
