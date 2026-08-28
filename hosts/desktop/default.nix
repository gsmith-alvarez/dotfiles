# Desktop host (spec from the development branch:
# DP-3 primary at x=0 + HDMI-A-1 at x=1920, study/utils workspaces).
# Shared base configs come from modules/common.nix.
{
  imports = [ (import ../host-module.nix { host = "desktop"; }) ];
}
