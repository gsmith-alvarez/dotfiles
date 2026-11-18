{ inputs, pkgs, ... }:
{
  # Integrates SOPS runtime decryption service; keys and encrypted secrets are enrolled separately.
  imports = [ inputs.sops-nix.nixosModules.sops ];
  environment.systemPackages = [
    pkgs.sops
    pkgs.age
    pkgs.ssh-to-age
  ];
}
