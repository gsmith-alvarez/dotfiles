# Laptop host (hostname: fedora — single built-in eDP-1 panel).
# Shared base configs come from modules/common.nix.
{
  imports = [ (import ../host-module.nix { host = "laptop"; }) ];
}
