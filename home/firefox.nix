{ pkgs, ... }:

let
  asPolicyPreference =
    status: settings:
    builtins.mapAttrs (_name: value: {
      Value = value;
      Status = status;
    }) settings;

  lockedPreferences = {
    "privacy.globalprivacycontrol.enabled" = true;
    "privacy.globalprivacycontrol.functionality.enabled" = true;
    "privacy.trackingprotection.emailtracking.enabled" = true;
    "network.trr.mode" = 2;
    "network.trr.uri" = "https://1.1.1.1/dns-query";
    "network.trr.excluded-domains" = "tailb7b5f7.ts.net,home.arpa";
    "dom.security.https_only_mode" = true;
    "media.peerconnection.ice.no_host" = true;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "app.shield.optoutstudies.enabled" = false;
    "browser.discovery.enabled" = false;
  };

  defaultPreferences = {
    "browser.startup.homepage" = "https://socialism.tailb7b5f7.ts.net/";
    "widget.use-xdg-desktop-portal.file-picker" = 1;
    "browser.tabs.drawInTitlebar" = true;
    "browser.toolbars.bookmarks.visibility" = "never";
    "browser.startup.page" = 3;
    "media.ffmpeg.vaapi.enabled" = true;
  };

  forceInstalledExtension = slug: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    default_area = "menupanel";
  };

  zoteroConnectorExtension = {
    installation_mode = "force_installed";
    update_url = "https://www.zotero.org/download/connector/firefox/release/updates.json";
    default_area = "menupanel";
  };

  uBlockExtensionSettings = {
    force = true;
    settings = {
      selectedFilterLists = [
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-unbreak"
        "ublock-quick-fixes"
      ];
    };
  };

  firefoxProfileExtensions = {
    force = true;
    settings."uBlock0@raymondhill.net" = uBlockExtensionSettings;
  };

  junction = pkgs.symlinkJoin {
    name = "junction";
    paths = [ pkgs.junction ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = "wrapProgram $out/bin/junction --prefix PATH : ${pkgs.junction}/bin";
  };

  firefoxProfileIcons =
    pkgs.runCommand "firefox-profile-icons"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        dir=$out/share/icons/hicolor/128x128/apps
        mkdir -p "$dir"
        src="${pkgs.firefox}/share/icons/hicolor/128x128/apps/firefox.png"
        cp "$src" "$dir/firefox-personal.png"
        magick "$src" -modulate 100,100,10 "$dir/firefox-school.png"
        magick "$src" -modulate 100,100,55 "$dir/firefox-clubs.png"
      '';
in
{
  home.packages = [
    junction
    firefoxProfileIcons
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # These policies apply to every profile managed by this Firefox package.
    policies = {
      DisableTelemetry = true;

      DisableFirefoxStudies = true;
      PasswordManagerEnabled = false;
      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
      };

      Preferences =
        (asPolicyPreference "locked" lockedPreferences)
        // (asPolicyPreference "default" defaultPreferences);

      # HTTP services on the private tailnet.
      HttpAllowlist = [
        "http://socialism.tailb7b5f7.ts.net"
        "http://socialism.tailb7b5f7.ts.net:8888"
      ];

      SearchEngines = {
        Default = "SearXNG";
        DefaultPrivate = "SearXNG";
        Add = [
          {
            Name = "SearXNG";
            URLTemplate = "http://socialism.tailb7b5f7.ts.net:8888/search?q={searchTerms}";
            Method = "GET";
            Alias = "sx";
            Description = "Private SearXNG metasearch";
          }
          {
            Name = "Google";
            URLTemplate = "https://www.google.com/search?q={searchTerms}";
            Method = "GET";
            Alias = "g";
            Description = "Google fallback search";
          }
        ];
      };

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = forceInstalledExtension "ublock-origin";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = forceInstalledExtension "bitwarden-password-manager";
        "@testpilot-containers" = forceInstalledExtension "multi-account-containers";
        "deArrow@ajay.app" = forceInstalledExtension "dearrow";
        "sponsorBlocker@ajay.app" = forceInstalledExtension "sponsorblock";
        "addon@darkreader.org" = forceInstalledExtension "darkreader";
        "jordanlinkwarden@gmail.com" = forceInstalledExtension "linkwarden";
        "qui@s0up4200" = forceInstalledExtension "qui";
        "zotero@chnm.gmu.edu" = zoteroConnectorExtension;
      };

      "3rdparty" = {
        Extensions = {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            environment.base = "https://socialism.tailb7b5f7.ts.net:8222";
          };
        };
      };
    };

    profiles = {
      personal = {
        id = 0;
        isDefault = true;
        extensions = firefoxProfileExtensions;
      };
      school = {
        id = 1;
        extensions = firefoxProfileExtensions;
      };
      clubs = {
        id = 2;
        extensions = firefoxProfileExtensions;
      };
    };
  };

  xdg.desktopEntries = {
    firefox = {
      name = "Personal";
      exec = "firefox -P personal %U";
      icon = "${firefoxProfileIcons}/share/icons/hicolor/128x128/apps/firefox-personal.png";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        "new-private-window" = {
          name = "New Private Window";
          exec = "firefox -P personal --private-window %U";
        };
      };
    };

    firefox-school = {
      name = "School";
      exec = "firefox -P school %U";
      icon = "${firefoxProfileIcons}/share/icons/hicolor/128x128/apps/firefox-school.png";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        "new-private-window" = {
          name = "New Private Window";
          exec = "firefox -P school --private-window %U";
        };
      };
    };

    firefox-clubs = {
      name = "Clubs";
      exec = "firefox -P clubs %U";
      icon = "${firefoxProfileIcons}/share/icons/hicolor/128x128/apps/firefox-clubs.png";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        "new-private-window" = {
          name = "New Private Window";
          exec = "firefox -P clubs --private-window %U";
        };
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "re.sonny.Junction.desktop";
      "text/xml" = "re.sonny.Junction.desktop";
      "application/xhtml+xml" = "re.sonny.Junction.desktop";
      "x-scheme-handler/http" = "re.sonny.Junction.desktop";
      "x-scheme-handler/https" = "re.sonny.Junction.desktop";
      "x-scheme-handler/hermes" = "hermes-desktop.desktop";
      "x-scheme-handler/discord" = "vesktop.desktop";
      "x-scheme-handler/mailto" = "userapp-Thunderbird-DTOZV3.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-DTOZV3.desktop";
      "message/rfc822" = "userapp-Thunderbird-DTOZV3.desktop";
      "x-scheme-handler/net.thunderbird" = "userapp-Thunderbird-XVWYV3.desktop";
      "x-scheme-handler/openbot" = "openbot.desktop";
      "x-scheme-handler/t3code" = "com.t3tools.T3Code.desktop";
      "x-scheme-handler/bitwarden" = "bitwarden.desktop";
    };
    associations.added = {
      "x-scheme-handler/http" = [
        "firefox.desktop"
        "firefox-school.desktop"
        "firefox-clubs.desktop"
      ];
      "x-scheme-handler/https" = [
        "firefox.desktop"
        "firefox-school.desktop"
        "firefox-clubs.desktop"
      ];
      "text/html" = [
        "firefox.desktop"
        "firefox-school.desktop"
        "firefox-clubs.desktop"
      ];
    };
  };

  dconf.settings = {
    "re/sonny/Junction" = {
      show-app-names = true;
    };
  };
  home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
}
