# Builds Home Manager file entries that symlink directly into the dotfiles
# checkout instead of the nix store, so config edits apply without a rebuild.
# attrs: <config target> = <path under configs/>; override: <target> = extra
# attrs merged into that single entry (e.g. force = true).

{
  root,
  mkOutOfStoreSymlink,
  overrides ? { },
}:
builtins.mapAttrs (
  target: path:
  {
    source = mkOutOfStoreSymlink "${root}/${path}";
  }
  // (overrides.${target} or { })
)
