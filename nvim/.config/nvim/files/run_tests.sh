#!/usr/bin/env bash
# run_tests.sh
# Run busted spec files under Neovim headless so real vim.* API is available.
#
# Usage:
#   ./tests/run_tests.sh                  # all specs
#   ./tests/run_tests.sh runners_spec     # single spec by name
#
# Requirements:
#   - nvim on PATH (nightly)
#   - busted on PATH (mise install lua / luarocks install busted)
#
# The script adds lua/ to nvim's runtimepath so require("build.runners")
# resolves correctly without needing a full plugin install.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="$REPO_ROOT/tests/build"
LUA_DIR="$REPO_ROOT/lua"

# Colour helpers
RED='\033[0;31m'; GREEN='\033[0;32m'; RESET='\033[0m'

pass=0; fail=0

run_spec() {
  local spec="$1"
  echo "▶  $(basename "$spec")"
  # nvim --headless -l <file> exits with the file's exit code.
  # We inject the lua/ dir via --cmd so require() works.
  if nvim --headless \
       --cmd "set rtp+=$LUA_DIR" \
       -l "$spec" 2>&1; then
    echo -e "   ${GREEN}PASS${RESET}"
    ((pass++)) || true
  else
    echo -e "   ${RED}FAIL${RESET}"
    ((fail++)) || true
  fi
  echo
}

if [[ $# -gt 0 ]]; then
  # Partial name match — e.g. "runners_spec" or "runners_fs"
  while IFS= read -r -d '' f; do
    run_spec "$f"
  done < <(find "$TESTS_DIR" -name "*${1}*_spec.lua" -print0)
else
  while IFS= read -r -d '' f; do
    run_spec "$f"
  done < <(find "$TESTS_DIR" -name "*_spec.lua" -print0)
fi

echo "Results: ${GREEN}${pass} passed${RESET}, ${RED}${fail} failed${RESET}"
[[ $fail -eq 0 ]]
