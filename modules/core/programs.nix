{ pkgs, ... }:
{
  programs = {
    nh = {
      enable = true;
      clean = {
        extraArgs = "--keep 5";
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
  ];
}
