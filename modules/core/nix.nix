let
  caches = import ../../lib/caches.nix;
in
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "giovanni" ];
    accept-flake-config = true;
    keep-outputs = true;
    http-connections = 50;
    extra-substituters = caches.substituters;
    extra-trusted-public-keys = caches.trusted-public-keys;
  };
}
