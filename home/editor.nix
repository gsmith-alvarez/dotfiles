{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true;
    withNodeJs = true;
    initLua = builtins.readFile ./nvim/init.lua;
  };

  # Automatically symlink all files and directories in ./nvim except init.lua
  xdg.configFile = builtins.listToAttrs (
    map (name: {
      name = "nvim/${name}";
      value = {
        source = ./nvim + "/${name}";
      };
    }) (builtins.filter (n: n != "init.lua") (builtins.attrNames (builtins.readDir ./nvim)))
  );

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
    pyright
    vscode-langservers-extracted # Provides JSON & HTML LSPs
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
    nixfmt

    # Graphics & Typesetting
    mermaid-cli
    tectonic
  ];
}
