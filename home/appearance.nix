_: {
  gtk = {
    enable = true;
    theme.name = "adw-gtk3-dark";
    iconTheme.name = "adwaita-icon-theme";
    cursorTheme.name = "adwaita-icon-theme";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  fonts.fontconfig.enable = true;
}
