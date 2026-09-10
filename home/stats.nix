{ pkgs, ... }:

#Apps needed for my stats class

let
  rPkgs = with pkgs.rPackages; [
    tidyverse
    devtools
    data_table
    ggplot2
    rmarkdown
    languageserver
  ];

  myR = pkgs.rWrapper.override { packages = rPkgs; };
  myRStudio = pkgs.rstudioWrapper.override { packages = rPkgs; };
in
{
  home.packages = [
    myR
    myRStudio
  ];
}
