#!/usr/bin/env bash
# check-layers.sh — Modifier-Layer Keybinding conformance gate.
#
# Enforces the "leader-key register": each modifier is owned by exactly one
# layer. The compositor (Niri) must NOT bind bare Ctrl or bare Alt (save the
# single sanctioned exception, Alt+Tab family). The terminal (Ghostty) must
# NOT bind Super/Mod.
#
# Usage:  ./scripts/check-layers.sh          # exits 1 on any violation
#         LAYERS=niri ./scripts/check-layers.sh   # only check one layer
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIRI_FILES=(
  "$REPO/niri/.config/niri/config.kdl"
  "$REPO/niri/.config/niri/dms/binds.kdl"
)
GHOSTTY_FILES=(
  "$REPO/ghostty/.config/ghostty/config"
)

violations=0

# ---- Niri: no bare Ctrl, bare Alt (except Alt+Tab/Alt+grave family) ----
check_niri() {
  local f
  for f in "${NIRI_FILES[@]}"; do
    [[ -f "$f" ]] || continue
    echo "→ niri: $(basename "$f")"
    # Bare Ctrl chords (Ctrl+X, not Mod+Ctrl / Ctrl+Shift / Ctrl+Alt combos)
    while IFS= read -r line; do
      violations=$((violations+1))
      echo "  ✗ bare Ctrl (must move off compositor): $line"
    done < <(grep -nE '(^|[[:space:]])(Ctrl\+[A-Za-z0-9])' "$f" \
        | grep -v '^\s*[0-9]*:\s*//' \
        | grep -vE 'Mod\+Ctrl|Ctrl\+Mod|Ctrl\+Shift|Ctrl\+Alt|Ctrl\+XF86|Ctrl\+Print|\+Ctrl' || true)
    # Bare Alt chords, except the sanctioned Alt+Tab / Alt+grave window-switch family
    while IFS= read -r line; do
      violations=$((violations+1))
      echo "  ✗ bare Alt (non-sanctioned): $line"
    done < <(grep -nE '(^|[[:space:]])Alt\+' "$f" \
        | grep -v '^\s*[0-9]*:\s*//' \
        | grep -vE 'Mod\+Alt|Alt\+Mod|Alt\+Shift|Alt\+Tab|Alt\+grave' || true)
  done
}

# ---- Ghostty: no Super/Mod ----
check_ghostty() {
  local f
  for f in "${GHOSTTY_FILES[@]}"; do
    [[ -f "$f" ]] || continue
    echo "→ ghostty: $(basename "$f")"
    while IFS= read -r line; do
      violations=$((violations+1))
      echo "  ✗ uses Super/Mod (compositor's modifier): $line"
    done < <(grep -nE 'super|Mod\+' "$f" || true)
  done
}

[[ "${LAYERS:-all}" != "ghostty" ]] && check_niri
[[ "${LAYERS:-all}" != "niri" ]]  && check_ghostty

echo ""
if (( violations == 0 )); then
  echo "✅ Register conformant: no modifier-layer violations."
  exit 0
else
  echo "❌ $violations modifier-layer violation(s) found."
  exit 1
fi
