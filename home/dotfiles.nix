{ config, ... }:
let
  links = import ../lib/out-of-store.nix {
    root = "${config.home.homeDirectory}/dotfiles/configs";
    inherit (config.lib.file) mkOutOfStoreSymlink;
    # Replace an existing unmanaged file; this does not resolve competing module definitions.
    overrides."fish/config.fish".force = true;
  };
in
{
  xdg.configFile =
    (links [
      "ghostty"
      "nvim"
      "atuin"
      "bat"
      "btop"
      "lazygit"
      "navi"
      "niri"
      "spotify-player"
      "starship.toml"
      "fastfetch"
      "fetch"
      "OpenTabletDriver"
      "topgrade.toml"
    ])
    // (links {
      # Sub-paths split because fish writes runtime state (e.g. fish_variables) into ~/.config/fish
      "fish/config.fish" = "fish/config.fish";
      "fish/conf.d" = "fish/conf.d";
      "fish/functions" = "fish/functions";
      "fish/completions" = "fish/completions";
    });

  home.file = links [
    ".gitconfig"
    ".gitignore_global"
  ];
  xdg.dataFile = links {
    "easyeffects/output/easyeffectpreset.json" = "easy-effects/easyeffectpreset.json";
    "easyeffects/input/Shure SM7B.json" = "easy-effects/Shure SM7B.json";
  };
}
