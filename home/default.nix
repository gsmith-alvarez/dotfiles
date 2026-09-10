{
  pkgs,
  inputs,
  llm-agents ? inputs.llm-agents,
  ...
}:
let
  llmpkgs = (inputs.llm-agents or llm-agents).packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./dotfiles.nix
  ];

  news.display = "show";

  programs.home-manager.enable = true;

  home = {
    username = "giovanni";
    homeDirectory = "/home/giovanni";
    stateVersion = "26.05";

    packages =
      (with pkgs; [
        # Editor / Git
        neovim
        git
        wget

        # Monitoring & Storage Inspection
        btop
        iotop
        procs
        hyperfine
        dust
        duf

        # Nix
        nix-tree
        nix-index
        nvd
        nix-diff
        nix-output-monitor
        nh
        comma
        nixfmt-rfc-style
        statix
        deadnix

        # Terminal
        ghostty
        fzf
        fd
        ripgrep
        ripgrep-all
        eza
        bat
        bat-extras.batgrep
        bat-extras.batman
        bat-extras.batwatch
        bat-extras.batdiff
        zoxide
        yazi
        sd

        # Applications
        keepassxc
        github-cli
        easyeffects

        # VM
        podman
        distrobox

        # CLI Tools
        xh
        delta
        tealdeer
        ouch
        grex
        doggo
        duckdb
        visidata
        usage
        watchexec
        fetch
        fastfetch
        impala

        # Structured Data & Docs
        jless
        yq-go
        glow

        # Networking
        gping
        trippy

        # Safe Removal & Utilities
        rm-improved
        rsync
        uv

        # Languages
        luajit
        zig
        nodejs
        bun

        # Language Servers
        lua-language-server
        bash-language-server
        vscode-json-languageserver
        yaml-language-server
        dockerfile-language-server
        clang-tools
        fish-lsp
        nil

        # Linters & Formatters
        ty
        typos
        stylua
        selene
        ruff
        shellcheck
        shfmt
        oxlint
        oxfmt
        taplo
        yamllint

        # Graphics & Typesetting
        mermaid-cli
        tectonic

        # Neovim plugin build toolchain
        rustc
        cargo
        tree-sitter
        gcc
        gnumake
      ])
      ++ (with llmpkgs; [
        hermes-agent
        hermes-desktop
        omp
      ]);
  };

  services.flatpak = {
    packages = [
      "md.obsidian.Obsidian"
      "app.zen_browser.zen"
    ];
  };
}
