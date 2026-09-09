{
  config,
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

  home.username = "giovanni";
  home.homeDirectory = "/home/giovanni";

  home.stateVersion = "26.05";

  news.display = "show";

  programs.home-manager.enable = true;

  home.packages =
    (with pkgs; [
      # Editor / Git
      neovim
      git
      wget

      # Monitoring
      btop
      iotop

      # Nix
      nix-tree
      nix-index
      nvd
      nix-diff
      nix-output-monitor
      nh

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

  services.flatpak = {
    packages = [
      "md.obsidian.Obsidian"
      "app.zen_browser.zen"
    ];
  };
}
