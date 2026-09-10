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

  # Package overlays for noctalia components
  nixpkgs.overlays = [
    (_final: prev: {
      noctalia = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;
      noctalia-greeter = inputs.noctalia-greeter.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];

  # Programs
  programs = {
    noctalia-greeter = {
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
          theme = "adwaita-icon-theme";
          size = 24;
        };
      };
    };

    noctalia = {
      enable = true;
    };

    niri.enable = true;
  };

  # X11 / Xwayland / Keyboard
  services.xserver = {
    enable = false;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
