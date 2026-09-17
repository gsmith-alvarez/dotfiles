{ pkgs, ... }:

let
  catppuccinCss = builtins.readFile ../configs/anki/catppuccin_mocha.css;

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
