{ pkgs, inputs, ... }:

let
  llmpkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  home.packages = with llmpkgs; [
    hermes-agent
    hermes-desktop
    omp
  ];
}
