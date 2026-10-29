{
  pkgs,
  inputs,
  ...
}:
let
  llmpkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages =
    (with pkgs; [
      # Editors & version control
      git
      github-cli
      lazygit
      neovim
      zed-editor

      # Containers
      distrobox
      podman

      # Change inspection & automation
      delta
      watchexec

      # Nix development
      deadnix
      nixfmt
      statix

      # Languages & runtimes
      bun
      luajit
      uv

      # Language servers
      bash-language-server
      clang-tools
      dockerfile-language-server
      fish-lsp
      lua-language-server
      nil
      rust-analyzer
      typos-lsp
      vscode-langservers-extracted
      yaml-language-server

      # Linters & formatters
      oxlint
      oxfmt
      ruff
      selene
      shellcheck
      shfmt
      stylua
      taplo
      ty
      typos
      yamllint

      # Docs & diagrams
      tectonic

      # Neovim plugin build toolchain
      cargo
      gcc
      gnumake
      rustc
      tree-sitter
    ])
    ++ (with llmpkgs; [
      antigravity-cli
      hermes-agent
      hermes-desktop
      omp
    ]);

  programs.rex.enable = true;
  services.rex.enable = true;
}
