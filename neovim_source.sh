#!/usr/bin/env bash
set -euo pipefail

cd ~/source/neovim

git fetch --prune
git reset --hard origin/master

sudo rm -rf zig-cache .zig-cache zig-out

sudo "$(which zig)" build install -Doptimize=ReleaseFast --prefix /usr/local
