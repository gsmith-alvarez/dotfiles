{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripes
  ];
}
