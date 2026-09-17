# Exercise the real NixOS/Home Manager module merge, not a mocked file manifest.
{
  lib,
  pkgs,
  nixos,
  check,
}:
let
  accepts = home: (builtins.tryEval (check home).drvPath).success;
  changedHome =
    module:
    (nixos.extendModules { modules = [ { home-manager.users.giovanni = module; } ]; })
    .config.home-manager.users.giovanni;
  replaced = changedHome {
    xdg.configFile.nvim.source = lib.mkForce (pkgs.writeText "link-contract-canary" "replaced");
  };
  disabled = changedHome {
    xdg.configFile.nvim.enable = lib.mkForce false;
  };
  missing = changedHome {
    home.file = lib.mkForce { };
  };
  moved = changedHome {
    xdg.configFile.nvim.target = lib.mkForce "nvim-moved";
  };
  unforced = changedHome {
    xdg.configFile."fish/config.fish".force = lib.mkForce false;
  };
in
assert accepts nixos.config.home-manager.users.giovanni;
assert !(accepts replaced);
assert !(accepts disabled);
assert !(accepts missing);
assert !(accepts moved);
assert !(accepts unforced);
true
