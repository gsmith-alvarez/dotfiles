{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Nix
    comma
    nix-index
    nix-output-monitor
    nvd

    # Terminal & search
    bat
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batwatch
    eza
    fd
    fzf
    ripgrep
    ripgrep-all
    sd
    zoxide

    # System & storage inspection
    btop
    duf
    dust
    iotop
    procs

    glow
    jless
    jq
    yq-go

    # Networking
    doggo
    wget
    xh

    # Utilities
    fastfetch
    fetch
    ouch
    rm-improved
    rsync
    tealdeer
    topgrade
    usage
  ];
}
