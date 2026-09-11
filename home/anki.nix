{ pkgs, ... }:

let
  catppuccinCss = pkgs.writeText "catppuccin_mocha.css" ''
    /* Catppuccin Mocha Theme for SynapsePro / Anki */
    :root {
        --primary-cyan: #89b4fa;
        --primary-cyan-dark: #74c7ec;
        --secondary-teal: #94e2d5;
        --secondary-teal-dark: #89dceb;
        --button-specific-blue: #89b4fa;
        --counter-new-color: #89b4fa;
        --counter-review-color: #a6e3a1;
        --medical-text-dark: #4c4f69;
        --medical-text-light: #eff1f5;
        --medical-bg-paper: #ffffff;
        --medical-bg-accent: #e6e9ef;
        --medical-border-color: #ccd0da;
        --border-radius: 6px;
        --deck-border-radius: 12px;
        --box-shadow-light: 0 2px 5px rgba(30, 30, 46, 0.1);
        --box-shadow-hover: 0 4px 8px rgba(30, 30, 46, 0.15);
    }

    body.nightMode {
        --primary-cyan: #89b4fa;
        --primary-cyan-dark: #74c7ec;
        --secondary-teal: #94e2d5;
        --secondary-teal-dark: #89dceb;
        --button-specific-blue: #89b4fa;
        --counter-new-color: #89b4fa;
        --counter-review-color: #a6e3a1;
        --medical-text-dark: #cdd6f4;
        --medical-text-light: #ffffff;
        --medical-bg-paper: #1e1e2e;
        --medical-bg-subtle: #181825;
        --medical-bg-accent: #313244;
        --medical-border-color: #45475a;
        --box-shadow-light: 0 2px 5px rgba(17, 17, 27, 0.4);
        --box-shadow-hover: 0 4px 8px rgba(17, 17, 27, 0.6);
    }

    body {
        color: var(--medical-text-dark);
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }

    html:has(body.deckbrowser),
    html:has(body.overview),
    html:has(body.review),
    html:has(#custom-dashboard),
    body.deckbrowser,
    body.overview,
    body.review,
    body:has(#custom-dashboard) {
        background: linear-gradient(0deg, #eff1f5 0%, #dce0e8 50%, #eff1f5 100%) !important;
        background-attachment: fixed !important;
    }

    html:has(body.nightMode.deckbrowser),
    html:has(body.nightMode.overview),
    html:has(body.nightMode.review),
    html:has(body.nightMode):has(#custom-dashboard),
    body.nightMode.deckbrowser,
    body.nightMode.overview,
    body.nightMode.review,
    body.nightMode:has(#custom-dashboard) {
        background: linear-gradient(0deg, #181825 0%, #1e1e2e 50%, #181825 100%) !important;
        background-attachment: fixed !important;
    }

    .deckbrowser .decks-container,
    .deckbrowser > center > table {
        background: var(--medical-bg-paper) !important;
        border-radius: var(--deck-border-radius) !important;
        box-shadow: none !important;
        border: 1px solid var(--medical-border-color) !important;
        overflow: hidden;
        box-sizing: border-box;
        position: relative;
        z-index: 1;
        margin-top: 15px;
        margin-bottom: 15px;
        margin-left: auto !important;
        margin-right: auto !important;
    }
    body.nightMode .deckbrowser .decks-container,
    body.nightMode .deckbrowser > center > table {
        background: var(--medical-bg-paper) !important;
        border-radius: var(--deck-border-radius) !important;
        box-shadow: none !important;
        border: 1px solid var(--medical-border-color) !important;
        overflow: hidden;
        box-sizing: border-box;
        position: relative;
        z-index: 1;
        margin-top: 15px;
        margin-bottom: 15px;
        margin-left: auto !important;
        margin-right: auto !important;
    }

    .deckbrowser td.count-fg.new-count, .deckbrowser span.new-count { color: var(--counter-new-color) !important; }
    .deckbrowser td.count-fg.review-count, .deckbrowser span.review-count { color: var(--counter-review-color) !important; }

    .deckbrowser td.count-fg,
    .deckbrowser th.count-label {
        width: 65px !important;
        min-width: 65px !important;
        max-width: 65px !important;
        text-align: right !important;
        padding-left: 0 !important;
    }

    .overview .deck-desc {
        background-color: var(--medical-bg-paper) !important;
        padding: 20px;
        border-radius: var(--border-radius);
        border: 1px solid var(--medical-border-color);
        margin-top: 20px;
        box-shadow: var(--box-shadow-light);
        line-height: 1.6;
        position: relative;
        z-index: 1;
    }
    body.nightMode .overview .deck-desc {
        background-color: var(--medical-bg-subtle) !important;
    }
    .overview h1 {
        color: var(--button-specific-blue);
        font-weight: 600;
        margin-bottom: 15px;
        position: relative;
        z-index: 1;
    }

    #outer {
        background: transparent !important;
        box-shadow: none !important;
        border: none !important;
        padding: 12px 0 !important;
    }

    body.top-toolbar {
        box-shadow: none !important;
        border-bottom: none !important;
    }

    body.top-toolbar div {
        box-shadow: none !important;
    }

    body.deckbrowser::-webkit-scrollbar,
    body:has(#custom-dashboard)::-webkit-scrollbar,
    html:has(body.deckbrowser)::-webkit-scrollbar,
    html:has(#custom-dashboard)::-webkit-scrollbar {
        width: 0 !important;
        height: 0 !important;
        display: none !important;
    }

    body.deckbrowser:not(.synapse-minimal-dashboard) .decks-container,
    body.deckbrowser:not(.synapse-minimal-dashboard) > center > table {
        min-width: 860px !important;
        max-width: 860px !important;
        width: 860px !important;
    }
  '';

  synapsePro = pkgs.anki-utils.buildAnkiAddon {
    pname = "synapse-pro";
    version = "1.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "mobesamedia";
      repo = "SynapsePro";
      rev = "d9db156b8a0845c0e7344e4e33b871eedbe39b7a";
      hash = "sha256-vSdsJdlxOa9lrhABNiTIsoT13rU0Nl5GufnMKit0HYY=";
    };
    postPatch = ''
        cp ${catppuccinCss} theme/user_files/catppuccin_mocha.css
        substituteInPlace __init__.py \
          --replace-fail '"active_theme": "medical_theme.css"' '"active_theme": "catppuccin_mocha.css"' \
          --replace-fail '"active_color_theme": "ocean"' '"active_color_theme": "catppuccin"'
        substituteInPlace theme.py \
          --replace-fail '"ocean": {' '"catppuccin": {
          False: {
              "blue":         "#1e66f5",
              "blue_hover":   "#04a5e5",
              "blue_pressed": "#7287fd",
              "blue_border":  "none",
              "blue_bright":  "#209fb5",
              "blue_accent":  "#1e66f5",
          },
          True: {
              "blue":         "#89b4fa",
              "blue_hover":   "#b4befe",
              "blue_pressed": "#74c7ec",
              "blue_border":  "1px solid #585b70",
              "blue_bright":  "#cba6f7",
              "blue_accent":  "#89b4fa",
          },
      },
      "ocean": {'
    '';
  };
in
{
  home.sessionVariables = {
    ANKI_WAYLAND = "1";
  };

  home.packages = [
    (pkgs.anki.withAddons [
      (pkgs.ankiAddons.passfail2.withConfig {
        config = {
          toggle_names_textcolors = "1";
          again_button_name = "Fail";
          good_button_name = "Pass";
          again_button_textcolor = "#f38ba8";
          good_button_textcolor = "#a6e3a1";
        };
      })
      (pkgs.ankiAddons.fsrs4anki-helper.withConfig {
        config = {
          days_to_reschedule = 10;
          auto_reschedule_after_sync = true;
          display_memory_state = true;
        };
      })
      synapsePro
    ])
  ];
}
