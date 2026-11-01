{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles.default = {
      id = 0;
      name = "personal";
      isDefault = true;

      settings = {
        "browser.startup.homepage" = "https://socialism.tailb7b5f7.ts.net/";
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };
  };
}
