{
  config,
  pkgs,
  lib,
  inputs,
  yazi-flavors ? inputs.yazi-flavors,
  ...
}:
let
  # Symlinks point directly at this directory, NOT the nix store —
  # edits here apply instantly (apps watch their config paths); no rebuild needed.
  cfg = "${config.home.homeDirectory}/dotfiles/configs";
  link = path: config.lib.file.mkOutOfStoreSymlink "${cfg}/${path}";

  fr-yazi = pkgs.runCommand "fr.yazi-0-unstable-2026-09-09" { } ''
    mkdir -p $out
    cp ${pkgs.fetchzip {
      url = "tarball+https://codeload.github.com/lpnh/fr.yazi/tar.gz/refs/heads/main";
      hash = "sha256-3D1mIQpEDik0ppPQo+/NIhCxEu/XEnJMJ0HiAFxlOE4=";
    }}/* $out/
  '';
in
{
  home.packages = with pkgs; [
    fish
    starship
    atuin
    lazygit
    navi
    fuzzel
    zed-editor
    cliphist
    wl-clipboard
    grim
    slurp
    satty
    jq
    spotify-player
    topgrade
    monaspace
    jetbrains-mono
  ];

  programs.yazi = {
    enable = true;
    enableFishIntegration = false;
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
      catppuccin-mocha = yazi-flavors.packages.${pkgs.stdenv.hostPlatform.system}.catppuccin-mocha;
    };
  };

  home.file = {
    ".config/fish/config.fish" = { source = link "fish/config.fish"; force = true; };
    ".config/fish/conf.d".source = link "fish/conf.d";
    ".config/fish/functions".source = link "fish/functions";
    ".config/fish/completions".source = link "fish/completions";

    ".config/ghostty/config".source = link "ghostty/config";
    ".config/ghostty/themes".source = link "ghostty/themes";

    ".config/nvim".source = link "nvim";

    ".config/starship.toml".source = link "starship.toml";

    ".config/atuin/config.toml".source = link "atuin/config.toml";
    ".config/atuin/themes".source = link "atuin/themes";

    ".config/bat/config".source = link "bat/config";
    ".config/bat/themes".source = link "bat/themes";

    ".config/btop/btop.conf".source = link "btop/btop.conf";
    ".config/btop/themes".source = link "btop/themes";

    ".config/lazygit/config.yml".source = link "lazygit/config.yml";
    ".config/lazygit/themes".source = link "lazygit/themes";

    ".config/navi/config.yaml".source = link "navi/config.yaml";
    ".config/navi/cheats".source = link "navi/cheats";

    ".config/niri/config.kdl".source = link "niri/config.kdl";

    ".config/spotify-player/app.toml".source = link "spotify-player/app.toml";
    ".config/spotify-player/theme.toml".source = link "spotify-player/theme.toml";

    ".config/fuzzel/fuzzel.ini".source = link "fuzzel/fuzzel.ini";

    ".config/OpenTabletDriver".source = link "OpenTabletDriver";

    ".config/fastfetch".source = link "fastfetch";
    ".config/fetch".source = link "fetch";

    ".gitconfig".source = link ".gitconfig";
    ".gitignore_global".source = link ".gitignore_global";

    ".local/bin/check-layers.sh" = {
      source = link "scripts/check-layers.sh";
    };

    ".local/bin/niri-screenshot.sh" = {
      source = link "scripts/niri-screenshot.sh";
    };
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];

  gtk.enable = true;
  gtk.theme.name = "adw-gtk3-dark";
  gtk.iconTheme.name = "adwaita-icon-theme";
  gtk.cursorTheme.name = "adwaita-icon-theme";
  gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
  gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  fonts.fontconfig.enable = true;
}
