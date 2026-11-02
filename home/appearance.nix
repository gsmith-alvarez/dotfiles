{ pkgs, ... }:
{
  gtk = {
    enable = true;
    theme.name = "adw-gtk3-dark";
    theme.package = pkgs.adw-gtk3;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  systemd.user.services.dconf-color-scheme = {
    Unit = {
      Description = "Set the desktop color scheme";
      Requires = [ "dconf.service" ];
      After = [ "dconf.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\"";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Qt apps follow the same system preference (dconf color-scheme) via
  # the QPA platform theme; adwaita-dark is the fallback style.
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = [
        pkgs.adwaita-qt
        pkgs.adwaita-qt6
      ];
    };
  };

  fonts.fontconfig.enable = true;
}
