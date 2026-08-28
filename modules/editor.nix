{ pkgs, ... }:

{
  # Editor everywhere so tools don't fall back to vi.
  home.sessionVariables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
    VISUAL = "${pkgs.neovim}/bin/nvim";
  };

  home.packages = with pkgs; [
    # Runtimes
    neovim
    nodejs_22
    bun
    zig
    watchexec
    luajit
    uv

    # LSPs
    lua-language-server
    bash-language-server
    ty
    vscode-langservers-extracted
    yaml-language-server
    dockerfile-language-server
    nixd
    pyright

    # Linters, Formatters & Checkers
    tree-sitter
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
    nixfmt
    statix
    deadnix

    # Graphics & Typesetting
    mermaid-cli
    tectonic
  ];
}
