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

  # Hardware video acceleration for Firefox and other desktop applications.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ libva-vdpau-driver ];
  };

  # Package overlays for noctalia and wayscriber components
  nixpkgs.overlays = [
    (_final: prev: {
      noctalia = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;
      noctalia-greeter = inputs.noctalia-greeter.packages.${prev.stdenv.hostPlatform.system}.default;
      openbot = inputs.openbot.packages.${prev.stdenv.hostPlatform.system}.openbot.overrideAttrs (old: {
        extraInstallCommands =
          builtins.replaceStrings [ "Exec=AppRun --no-sandbox %U" ] [ "Exec=AppRun %U" ]
            old.extraInstallCommands;
      });
      wayscriber =
        inputs.wayscriber.packages.${prev.stdenv.hostPlatform.system}.wayscriber.overrideAttrs
          (_old: {
            doCheck = false;
          });
      wayscriber-configurator =
        let
          configurator =
            inputs.wayscriber.packages.${prev.stdenv.hostPlatform.system}.wayscriber-configurator;
        in
        prev.symlinkJoin {
          name = "${configurator.name}-with-gsettings";
          paths = [ configurator ];
          nativeBuildInputs = [ prev.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/wayscriber-configurator \
              --prefix PATH : ${prev.lib.makeBinPath [ prev.glib.bin ]}
          '';
          meta = configurator.meta;
        };
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
}
