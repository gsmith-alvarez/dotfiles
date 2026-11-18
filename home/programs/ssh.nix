{
  config,
  lib,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      rclone
      sshfs
    ];

    # Home Manager symlinks ~/.ssh/config into /nix/store, and OpenSSH refuses to
    # read the default user config unless it is owned by the invoking user:
    #   Bad owner or permissions on /home/giovanni/.ssh/config
    # Install a real copy of the generated config at activation instead, so the
    # file belongs to giovanni rather than to the Nix store.
    file.".ssh/config".enable = false;

    activation.installSshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run install -d -m 0700 "$HOME/.ssh"
      run rm -f "$HOME/.ssh/config"
      run install -m 0600 ${lib.escapeShellArg config.home.file.".ssh/config".source} "$HOME/.ssh/config"
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      yorku_labs = {
        HostName = "red.eecs.yorku.ca";
        User = "gsmitha";
        IdentityFile = "~/.ssh/york_lab_keys";
      };
    };
  };

}
