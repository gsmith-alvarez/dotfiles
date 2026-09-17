{ config, ... }:
let
  links = import ../lib/out-of-store.nix {
    root = "${config.home.homeDirectory}/dotfiles/configs";
    inherit (config.lib.file) mkOutOfStoreSymlink;
    overrides."fish/config.fish".force = true;
  };
in
{
  xdg.configFile = links {
    "fish/config.fish" = "fish/config.fish";
    "fish/conf.d" = "fish/conf.d";
    "fish/functions" = "fish/functions";
    "fish/completions" = "fish/completions";

    "ghostty/config" = "ghostty/config";
    "ghostty/themes" = "ghostty/themes";

    "nvim" = "nvim";

    "starship.toml" = "starship.toml";

    "atuin/config.toml" = "atuin/config.toml";
    "atuin/themes" = "atuin/themes";

    "bat/config" = "bat/config";
    "bat/themes" = "bat/themes";

    "btop/btop.conf" = "btop/btop.conf";
    "btop/themes" = "btop/themes";

    "lazygit/config.yml" = "lazygit/config.yml";
    "lazygit/themes" = "lazygit/themes";

    "navi/config.yaml" = "navi/config.yaml";
    "navi/cheats" = "navi/cheats";

    "niri/config.kdl" = "niri/config.kdl";

    "spotify-player/app.toml" = "spotify-player/app.toml";
    "spotify-player/theme.toml" = "spotify-player/theme.toml";

    "OpenTabletDriver" = "OpenTabletDriver";

    "fastfetch" = "fastfetch";
    "fetch" = "fetch";
  };

  home.file = links {
    ".gitconfig" = ".gitconfig";
    ".gitignore_global" = ".gitignore_global";
  };

  xdg.dataFile = links {
    "easyeffects/output/easyeffectpreset.json" = "easy-effects/easyeffectpreset.json";
    "easyeffects/input/Shure SM7B.json" = "easy-effects/Shure SM7B.json";
  };
}
