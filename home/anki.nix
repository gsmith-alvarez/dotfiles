{ pkgs, ... }:

let
  sources = pkgs.callPackage ../_sources/generated.nix { };
  catppuccinCss = pkgs.writeText "catppuccin_mocha.css" (
    builtins.readFile ../configs/anki/catppuccin_mocha.css
  );

  flowTimer = pkgs.anki-utils.buildAnkiAddon {
    pname = "flow-timer";
    version = builtins.substring 2 10 sources.flow-timer.version;
    src = sources.flow-timer.src;
    nativeBuildInputs = [ pkgs.unzip ];
    sourceRoot = "source";
    unpackPhase = ''
      runHook preUnpack
      mkdir source
      unzip -q "$src" -d source
      runHook postUnpack
    '';
    postPatch = ''
      substituteInPlace __init__.py \
        --replace-fail 'USER_FILES_DIR = os.path.join(ADDON_DIR, "user_files")' \
          'USER_FILES_DIR = os.path.join(os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share"), "anki", "flow-timer")' \
        --replace-fail 'data = mw.addonManager.getConfig(__name__)' \
          'data = _read_json_file(os.path.join(USER_FILES_DIR, "config.json"))' \
        --replace-fail 'mw.addonManager.writeConfig(__name__, data)' \
          'return _write_json_file(os.path.join(USER_FILES_DIR, "config.json"), data)'
    '';
  };

  synapse = pkgs.anki-utils.buildAnkiAddon {
    pname = "synapse";
    src = sources.synapse.src;
    version = sources.synapse.date;
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
      pkgs.ankiAddons.review-heatmap
      flowTimer
      synapse
    ])
  ];
}
