{ pkgs, config, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
    withNodeJs = true;
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim";

  home.packages = with pkgs; [
    # Runtimes
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

    # Linters, Formatters & Checkers
    tree-sitter
    typos
    stylua
    selene
    ruff
    shellcheck
    shfmt
    oxlint
    taplo
    yamllint
    nixfmt-rfc-style
    statix
    deadnix

    # Graphics & Typesetting
    mermaid-cli
    tectonic
  ];
}
