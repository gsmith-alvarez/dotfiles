{ lib, pkgs, ... }:
{
  users.users.giovanni = {
    isNormalUser = true;
    description = "giovanni";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # Keep these ahead of Home Manager's package environment.
    packages = lib.mkBefore (
      with pkgs;
      [
        nautilus
        wayscriber
      ]
    );

    shell = pkgs.fish;
  };
}
