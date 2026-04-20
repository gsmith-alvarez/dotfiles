#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$ROOT_DIR/tests/build"
BUSTED_CONFIG="$ROOT_DIR/tests/.busted"

pass=0
fail=0

run_one() {
	local spec="$1"
	echo "▶ $(basename "$spec")"
	if busted --no-coverage -c "$BUSTED_CONFIG" "$spec"; then
		echo "   PASS"
		pass=$((pass + 1))
	else
		echo "   FAIL"
		fail=$((fail + 1))
	fi
	echo
}

if ! command -v busted >/dev/null 2>&1; then
	echo "busted not found on PATH"
	echo "Install with: luarocks install busted"
	exit 1
fi

if [[ $# -gt 0 ]]; then
	while IFS= read -r -d '' f; do
		run_one "$f"
	done < <(find "$TEST_DIR" -type f -name "*${1}*.lua" -print0)
else
	while IFS= read -r -d '' f; do
		run_one "$f"
	done < <(find "$TEST_DIR" -type f -name "*_spec.lua" -print0)
fi

echo "Results: ${pass} passed, ${fail} failed"
[[ $fail -eq 0 ]]
