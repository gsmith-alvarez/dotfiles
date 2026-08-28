# uv2nix: build Python virtual environments from uv.lock files.
#
# KEPT AS STANDING INFRASTRUCTURE for first-party Python projects.
#
# marimo attempt (see git history 8da40e6) taught us:
#   1. Workspace needs real source — a vendored pyproject.toml + uv.lock
#      can't build an editable-root package (marimo/__init__.py missing).
#   2. deps.all pulls optional extras (CUDA/nvidia wheels wanting RDMA
#      system libs auto-patchelf can't satisfy) → use deps.default, or
#      pass an explicit extras spec.
#   3. sdist-only packages (csscompressor, jsmin, lzstring in marimo's
#      lock) need setuptools injected via pyprojectOverrides.
#
# The full pipeline below is complete and works when pointed at a
# first-party workspace (a repo of yours with a COMMITTED uv.lock):
#
#   let
#     workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
#       workspaceRoot = <your project>;
#     };
#     overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
#     pythonSet = (pkgs.callPackage inputs.pyproject-nix.build.packages {
#       python = pkgs.python312;
#     }).overrideScope (lib.composeManyExtensions [
#       inputs.pyproject-build-systems.overlays.wheel
#       overlay
#       pyprojectOverrides
#     ]);
#     venv = pythonSet.mkVirtualEnv "my-venv" workspace.deps.default;
#   in home.packages = [ venv ];
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # No venv built by default today — marimo (the last candidate) comes
  # from nixpkgs instead, and no first-party uv project needs pinning yet.
  # To activate for a project: point workspaceRoot at it and add the venv
  # to home.packages using the pipeline documented above.
}
