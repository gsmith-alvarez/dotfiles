{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # Import SOPS on both hosts; Easley's secrets are declared below.
  imports = [ inputs.sops-nix.nixosModules.sops ];
  environment.systemPackages = [
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
  ];

  sops = {
    defaultSopsFile = ../../secrets/easley.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = lib.mkIf (config.networking.hostName == "easley") {
      "openrouter/api-key" = {
        owner = "giovanni";
        mode = "0400";
      };
    };
  };
}
