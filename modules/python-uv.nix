# uv2nix: build Python virtual environments from uv.lock files.
#
# WIRING IN PLACE, NOT ACTIVE for any package yet. Documented findings from
# the attempted marimo conversion (commit history has details):
#
# 1. The marimo fork gitignores uv.lock → workspace had to be vendored
#    (configs/uv/marimo/ holds pyproject.toml + uv.lock).
# 2. deps.all pulls marimo's CUDA extras (nvidia/torch wheels) whose
#    RDMA libs (libmlx5, librdmacm) auto-patchelf can't satisfy →
#    use deps.default or an explicit extras list.
# 3. Editable workspace roots need real source (vendored pyproject alone
#    can't build the marimo package itself).
# 4. nixpkgs already ships marimo 0.23.16 = the fork's pinned version, so
#    `pkgs.marimo` covers the application need today (see modules/common.nix
#    usage via packages overlay if desired).
#
# When a first-party Python project (with a committed uv.lock) lands:
#   nix run github:pyproject-nix/uv2nix -- ... (or hand-write the module
#   body below, which is complete and working except for the workspace root).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # No venv packages produced yet — the full working pipeline (workspace
  # load → overlays → pyprojectOverrides for sdist-only packages →
  # mkVirtualEnv) is preserved in git history (modules/python-uv.nix at
  # the marimo-attempt commits) ready to point at a first-party workspace.
}
