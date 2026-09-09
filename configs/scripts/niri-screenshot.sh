#!/usr/bin/env bash
# Screenshot for niri, modeled on Omarchy's omarchy-capture-screenshot.
# Usage: niri-screenshot.sh [smart|region|fullscreen|window] [slurp|copy|save]

set -u

OUTPUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$OUTPUT_DIR"

# re-run while a selection is pending = cancel it
pkill slurp 2>/dev/null && exit 0

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

JQ_OUT_GEO='"\(.logical.x | floor),\(.logical.y | floor) \(.logical.width | floor)x\(.logical.height | floor)"'

open_editor() {
  local filepath="$1"
  satty --filename "$filepath" \
    --output-filename "$filepath" \
    --actions-on-enter save-to-clipboard \
    --save-after-copy \
    --copy-command 'wl-copy'
}

notify() {
  notify-send "$1" "${2:-}" -t 3000 -i "$3" 2>/dev/null
}

case "$MODE" in
region)
  SELECTION=$(slurp 2>/dev/null)
  ;;
fullscreen)
  SELECTION=$(niri msg --json focused-output | jq -r "$JQ_OUT_GEO")
  ;;
window)
  # niri picks the window under the cursor; grim its computed rect
  WID=$(niri msg --json pick-window 2>/dev/null | jq -r '.id // empty')
  [[ -z $WID ]] && exit 0
  GEO=$(niri msg --json windows | jq -r --argjson id "$WID" '
    .[] | select(.id == $id) |
    .layout.tile_pos_in_workspace_view as $p |
    if $p then
      "\($p[0] | floor),\($p[1] | floor) \(.layout.tile_size[0] | floor)x\(.layout.tile_size[1] | floor)"
    else empty end')
  [[ -z $GEO ]] && exit 0
  SELECTION=$GEO
  ;;
smart | *)
  # rects: full output + every visible window; slurp snaps while dragging
  RECTS=$(
    {
      niri msg --json focused-output | jq -r "$JQ_OUT_GEO"
      niri msg --json windows | jq -r '
        .[] | select(.layout.tile_pos_in_workspace_view != null) |
        .layout.tile_pos_in_workspace_view as $p |
        "\($p[0] | floor),\($p[1] | floor) \(.layout.tile_size[0] | floor)x\(.layout.tile_size[1] | floor)"'
    } | sort -u
  )

  SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)

  # tiny drag = treat as click, expand to the rect under the point
  if [[ $SELECTION =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
    if ((${BASH_REMATCH[3]} * ${BASH_REMATCH[4]} < 20)); then
      click_x="${BASH_REMATCH[1]}"
      click_y="${BASH_REMATCH[2]}"
      while IFS= read -r rect; do
        if [[ $rect =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
          rx="${BASH_REMATCH[1]}" ry="${BASH_REMATCH[2]}"
          rw="${BASH_REMATCH[3]}" rh="${BASH_REMATCH[4]}"
          if ((click_x >= rx && click_x < rx + rw && click_y >= ry && click_y < ry + rh)); then
            SELECTION="$rx,$ry ${rw}x${rh}"
            break
          fi
        fi
      done <<<"$RECTS"
    fi
  fi
  ;;
esac

[[ -z ${SELECTION:-} ]] && exit 0

FILENAME="screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$OUTPUT_DIR/$FILENAME"

case "$PROCESSING" in
copy)
  grim -g "$SELECTION" - | wl-copy
  notify "Screenshot" "Copied to clipboard"
  ;;
save)
  grim -g "$SELECTION" "$FILEPATH" || exit 1
  notify "Screenshot saved" "$FILEPATH" "$FILEPATH"
  ;;
slurp | *)
  grim -g "$SELECTION" "$FILEPATH" || exit 1
  wl-copy <"$FILEPATH"
  (
    ACTION=$(notify-send "Screenshot saved to clipboard and file" "Click to edit" -t 10000 -i "$FILEPATH" -A "default=edit")
    [[ ${ACTION:-} == "default" ]] && open_editor "$FILEPATH"
  ) >/dev/null 2>&1 &
  ;;
esac
