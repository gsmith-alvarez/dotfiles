#!/usr/bin/env bash
# Verify modifier ownership across the Nix-managed compositor and terminal configs.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIRI_FILE="$REPO/configs/niri/config.kdl"
GHOSTTY_FILE="$REPO/configs/ghostty/config"
violations=0

check_niri() {
    echo "→ niri: $(basename "$NIRI_FILE")"

    while IFS= read -r line; do
        violations=$((violations + 1))
        echo "  ✗ bare Ctrl (must stay out of the compositor): $line"
    done < <(
        grep -nE '(^|[[:space:]])Ctrl\+[A-Za-z0-9]' "$NIRI_FILE" \
            | grep -vE '(^|:)\s*//' \
            | grep -vE 'Mod\+Ctrl|Ctrl\+Mod|Ctrl\+Shift|Ctrl\+Alt|Ctrl\+XF86|Ctrl\+Print|\+Ctrl' \
            || true
    )

    while IFS= read -r line; do
        violations=$((violations + 1))
        echo "  ✗ bare Alt (only recent-window switching is allowed): $line"
    done < <(
        grep -nE '(^|[[:space:]])Alt\+' "$NIRI_FILE" \
            | grep -vE '(^|:)\s*//' \
            | grep -vE 'Mod\+Alt|Alt\+Mod|Alt\+Shift|Alt\+Tab|Alt\+grave' \
            || true
    )
}

check_ghostty() {
    echo "→ ghostty: $(basename "$GHOSTTY_FILE")"

    while IFS= read -r line; do
        violations=$((violations + 1))
        echo "  ✗ uses Mod/Super (compositor-owned modifier): $line"
    done < <(grep -nEi 'super|Mod\+' "$GHOSTTY_FILE" || true)
}

check_niri
check_ghostty

echo
if (( violations == 0 )); then
    echo "✅ Register conformant: no modifier-layer violations."
    exit 0
fi

echo "❌ $violations modifier-layer violation(s) found."
exit 1
