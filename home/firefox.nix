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
in
{
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

      # SearXNG is served over HTTP on the private tailnet.
      HttpAllowlist = [
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
    firefox-school = {
      name = "Firefox (School)";
      exec = "firefox --no-remote -P school %U";
      icon = "firefox";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
    };

    firefox-clubs = {
      name = "Firefox (Clubs)";
      exec = "firefox --no-remote -P clubs %U";
      icon = "firefox";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
    };
  };

  home.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
}
