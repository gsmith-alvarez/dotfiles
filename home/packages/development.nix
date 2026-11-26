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

      # Containers
      distrobox
      podman
      lazydocker
      isd
      systemctl-tui

      # Change inspection & automation
      delta
      watchexec

      # Nix development
      deadnix
      nixfmt
      statix

      # Languages & runtimes
      python3
      uv

      # Language servers
      bash-language-server
      dockerfile-language-server
      fish-lsp
      lua-language-server
      nil
      typos-lsp
      vscode-langservers-extracted
      yaml-language-server

      # Linters & formatters
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
      imagemagick

      # Neovim plugin build toolchain
      cargo
      cargo-update
      gcc
      gnumake
      rustc
      tree-sitter
    ])
    ++ (with llmpkgs; [
      antigravity-cli
      antigravity-hub
      omp
    ]);

  programs.rex.enable = true;
  services.rex.enable = true;
}
