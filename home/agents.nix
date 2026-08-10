{ pkgs, inputs, ... }:

let
  llmpkgs = inputs.llm-agents.packages.${pkgs.system};
in

{
  home.packages = with llmpkgs; [
    hermes-agent
    hermes-desktop
    omp
  ];
}
