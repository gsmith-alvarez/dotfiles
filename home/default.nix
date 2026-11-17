{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nix-index-database.homeModules.nix-index
    inputs.rex.homeManagerModules.default
    ./dotfiles.nix
    ./shell.nix
    ./yazi.nix
    ./appearance.nix
    ./anki.nix
    ./development.nix
    ./tools.nix
    ./applications.nix
    ./firefox.nix
    ./ssh.nix
  ];

  news.display = "show";

  programs.home-manager.enable = true;

  home = {
    username = "giovanni";
    homeDirectory = "/home/giovanni";
    # Pins Home Manager state conventions; do not change across release updates.
    stateVersion = "26.05";

    # Unlink legacy directory symlink before Home Manager links niri/config.kdl and niri/host.kdl.
    activation.migrateNiriDirSymlink = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      if [ -L ${lib.escapeShellArg "${config.xdg.configHome}/niri"} ]; then
        run rm ${lib.escapeShellArg "${config.xdg.configHome}/niri"}
      fi
    '';
  };
}
