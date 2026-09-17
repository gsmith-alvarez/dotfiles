{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Nix
    comma
    nix-diff
    nix-index
    nix-output-monitor
    nix-tree
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
    hyperfine
    iotop
    procs

    # Docs & data
    duckdb
    glow
    jless
    jq
    visidata
    yq-go

    # Networking
    doggo
    gping
    trippy
    wget
    xh

    # Utilities
    fastfetch
    fetch
    grex
    ouch
    rm-improved
    rsync
    tealdeer
    topgrade
    usage
  ];
}
