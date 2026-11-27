{ inputs, ... }:
{
  imports = [ inputs.hex.homeManagerModules.hex ];

  programs.hex = {
    enable = true;
    autostart = true;
    # Keep the Niri binding in configs/niri/config.kdl in sync; the shortcut portal may not bind it.
    shortcut = "control+option+space";
    model = "parakeet_v3";
    language = "en";
    installModel = true;
    # Use your compositor's session target if needed:
    # Niri Doesn't need
    # systemdTarget = "sway-session.target";

    # Optional declarative settings:
    settings = {
      shortcut_mode = "toggle";
      sound_effect_volume = 0.4;
      paste_with_shift = true;
      "meetings.enabled" = true;
      "labs.live_text" = true;
      "labs.faster_live_text" = true;
      "labs.live_typing" = true;
      "labs.unload_idle_minutes" = 15;
      "labs.unload_idle" = true;
      "labs.spoken_formatting" = true;
      "labs.filler_words" = true;
      "labs.modes_editor" = true;
      "labs.skip_pauses" = true;
    };
  };
}
