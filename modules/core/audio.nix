{ pkgs, ... }:

{
  security = {
    rtkit.enable = true;
    # Grant @audio users realtime scheduling (SCHED_FIFO) and unlocked memory for DAW DSP threads.
    pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "95";
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = "-19";
      }
    ];
  };

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Provide the pw-jack wrapper without setting a global LD_LIBRARY_PATH.
  environment.systemPackages = [ pkgs.pipewire.jack ];
}
