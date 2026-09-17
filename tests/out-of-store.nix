let
  links = import ../lib/out-of-store.nix {
    root = "/home/test/dotfiles/configs";
    mkOutOfStoreSymlink = path: path;
  };
  actual = links {
    "fish/config.fish" = "fish/config.fish";
    "easyeffects/input/Shure SM7B.json" = "easy-effects/Shure SM7B.json";
    ".gitconfig" = ".gitconfig";
  };
in
assert actual."fish/config.fish".source == "/home/test/dotfiles/configs/fish/config.fish";
assert actual."easyeffects/input/Shure SM7B.json".source == "/home/test/dotfiles/configs/easy-effects/Shure SM7B.json";
assert actual.".gitconfig".source == "/home/test/dotfiles/configs/.gitconfig";
assert links { } == { };
true
