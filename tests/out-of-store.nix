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
  merged =
    import ../lib/out-of-store.nix
      {
        root = "/home/test/dotfiles/configs";
        mkOutOfStoreSymlink = p: p;
        overrides."a".force = true;
      }
      {
        "a" = "x";
        "b" = "y";
      };
in
assert links { } == { };
assert actual."fish/config.fish".source == "/home/test/dotfiles/configs/fish/config.fish";
assert
  actual."easyeffects/input/Shure SM7B.json".source
  == "/home/test/dotfiles/configs/easy-effects/Shure SM7B.json";
assert actual.".gitconfig".source == "/home/test/dotfiles/configs/.gitconfig";
assert merged.a.force == true;
assert merged.a.source == "/home/test/dotfiles/configs/x";
assert merged.b.source == "/home/test/dotfiles/configs/y";
assert !(merged.b ? force);
true
