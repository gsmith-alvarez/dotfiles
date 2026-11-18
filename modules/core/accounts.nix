{ lib, pkgs, ... }:
{
  users.users.giovanni = {
    isNormalUser = true;
    description = "giovanni";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      # USB access for MCU
      "dialout"
      "plugdev"
    ];
    # Keep these ahead of Home Manager's package environment.
    packages = lib.mkBefore (
      with pkgs;
      [
        thunar
      ]
    );

    shell = pkgs.fish;
  };
}
