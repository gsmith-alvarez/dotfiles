{ pkgs, ... }:

{
  systemd.user.services = {
    wayscriber = {
      Unit = {
        Description = "Wayscriber - Screen annotation tool for Wayland";
        Documentation = "https://wayscriber.com";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
      };
      Service = {
        Type = "simple";
        ExecStartPre = [
          (pkgs.writeShellScript "wayscriber-prewait" ''
            [ -n "$WAYLAND_DISPLAY" ] && [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]
          '')
        ];
        ExecStart = "/usr/bin/wayscriber --daemon";
        Restart = "on-failure";
        RestartSec = 5;
        RestartPreventExitStatus = 75;
        SuccessExitStatus = [ "75" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    syncthing = {
      Unit = {
        Description = "Syncthing - Open Source Continuous File Synchronization";
        Documentation = "man:syncthing(1)";
        StartLimitIntervalSec = 60;
        StartLimitBurst = 4;
      };
      Service = {
        Environment = [
          "STLOGFORMATTIMESTAMP="
          "STLOGFORMATLEVELSTRING=false"
          "STLOGFORMATLEVELSYSLOG=true"
        ];
        ExecStart = "/usr/bin/syncthing serve --no-browser --no-restart";
        Restart = "on-failure";
        RestartSec = 1;
        SuccessExitStatus = [
          "3"
          "4"
        ];
        RestartForceExitStatus = [
          "3"
          "4"
        ];
        SystemCallArchitectures = "native";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    dsearch = {
      Unit = {
        Description = "dsearch - Fast filesystem search service";
        Documentation = "https://github.com/AvengeMedia/dsearch";
        After = "network.target";
      };
      Service = {
        Type = "simple";
        ExecStart = "/usr/bin/dsearch serve";
        Restart = "on-failure";
        RestartSec = "5s";
        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "dsearch";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
