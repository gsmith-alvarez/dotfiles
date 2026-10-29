{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
    inputs.noctalia.nixosModules.default
  ];

  # Package overlays for noctalia and wayscriber components
  nixpkgs.overlays = [
    (_final: prev: {
      noctalia = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;
      noctalia-greeter = inputs.noctalia-greeter.packages.${prev.stdenv.hostPlatform.system}.default;
      wayscriber =
        inputs.wayscriber.packages.${prev.stdenv.hostPlatform.system}.wayscriber.overrideAttrs
          (_old: {
            doCheck = false;
          });
      wayscriber-configurator =
        inputs.wayscriber.packages.${prev.stdenv.hostPlatform.system}.wayscriber-configurator;
    })
  ];

  # Programs
  programs = {
    noctalia = {
      enable = true;
    };

    niri.enable = true;
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    passwordless-sync-users = [ "giovanni" ];
    settings = {
      user.default = "giovanni";
      session.default = "Niri";
      output = {
        scale = 1.25;
        scales = "eDP-1:1.25; DP-1:1.5; DP-2:1.5";
      };
      cursor = {
        path = pkgs.adwaita-icon-theme;
        theme = "Adwaita";
        size = 24;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    wayscriber
    wayscriber-configurator
    grim
    slurp
    (tesseract.override { enableLanguages = [ "eng" ]; })
  ];

  systemd.packages = [ pkgs.wayscriber ];

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
  # Polkit authentication agent so privileged GUI dialogs get a password prompt
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
