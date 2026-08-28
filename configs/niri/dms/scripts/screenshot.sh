#!/usr/bin/env bash
# Interactive screenshot tool for Niri (Windows Snipping Tool style)
# Uses DMS's built-in screenshot module for capture + clipboard + notification.
#
# Modes (via fuzzel menu):
#   Region (default) — draw a rectangle to capture
#   Active Monitor   — capture the monitor containing the cursor
#   All Monitors     — capture all monitors in one image

set -euo pipefail

MODE=$(printf "Region\nActive Monitor\nAll Monitors" \
    | fuzzel --dmenu --prompt="Screenshot:" --lines=3 --width=25) || exit 0

case "$MODE" in
    "Region")
        dms screenshot region --no-confirm
        ;;
    "Active Monitor")
        dms screenshot full
        ;;
    "All Monitors")
        dms screenshot all
        ;;
esac