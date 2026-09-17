{ pkgs, inputs, ... }:
let
  fr-yazi = pkgs.runCommand "fr.yazi-0-unstable-2026-09-09" { } ''
    mkdir -p $out
    cp ${
      pkgs.fetchzip {
        url = "https://codeload.github.com/lpnh/fr.yazi/tar.gz/refs/heads/main";
        extension = "tar.gz";
        hash = "sha256-3D1mIQpEDik0ppPQo+/NIhCxEu/XEnJMJ0HiAFxlOE4=";
      }
    }/* $out/
  '';
in
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = false;
    # Configs are read into the store at build time to compose plugins and flavors hermetically.
    # Unlike live out-of-store symlinks, modifying files in configs/yazi/ requires a rebuild.
    initLua = ../configs/yazi/init.lua;
    keymap = builtins.fromTOML (builtins.readFile ../configs/yazi/keymap.toml);
    settings = builtins.fromTOML (builtins.readFile ../configs/yazi/yazi.toml);
    theme = builtins.fromTOML (builtins.readFile ../configs/yazi/theme.toml);
    vfs = builtins.fromTOML (builtins.readFile ../configs/yazi/vfs.toml);
    plugins = {
      git = pkgs.yaziPlugins.git;
      chmod = pkgs.yaziPlugins.chmod;
      smart-filter = pkgs.yaziPlugins.smart-filter;
      mount = pkgs.yaziPlugins.mount;
      full-border = pkgs.yaziPlugins.full-border;
      jump-to-char = pkgs.yaziPlugins.jump-to-char;
      ouch = pkgs.yaziPlugins.ouch;
      starship = pkgs.yaziPlugins.starship;
      fr = fr-yazi;
    };
    flavors = {
      catppuccin-mocha = inputs.yazi-flavors.packages.${pkgs.stdenv.hostPlatform.system}.catppuccin-mocha;
    };
  };

}
