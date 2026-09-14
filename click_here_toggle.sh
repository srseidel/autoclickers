#!/bin/bash
# ============================================================
# Click Here — left-clicks wherever the cursor is, once every
# second, while enabled. Run it, then use the keys below:
#   [space]  start/stop clicking
#   [q]      quit the script
# Requires cliclick:  brew install cliclick
# ============================================================

# ===================== SETTINGS =============================
INTERVAL_SECONDS=1      # seconds between each click
# ============================================================

CLICLICK="$(command -v cliclick || echo /opt/homebrew/bin/cliclick)"
ONFILE="/tmp/click_here.on"

if [ ! -x "$CLICLICK" ]; then
    echo "cliclick not found — run: brew install cliclick" >&2
    exit 1
fi

rm -f "$ONFILE"
cleanup() { rm -f "$ONFILE"; }
trap cleanup EXIT

# Background loop: click at the current cursor position while ONFILE exists
(
    while true; do
        [ -f "$ONFILE" ] && "$CLICLICK" c:.
        sleep "$INTERVAL_SECONDS"
    done
) &
LOOP_PID=$!
trap 'cleanup; kill "$LOOP_PID" 2>/dev/null' EXIT

echo "Clicking OFF. Press [space] to start/stop, [q] to quit."
while true; do
    IFS= read -rsn1 key
    case "$key" in
        " ")
            if [ -f "$ONFILE" ]; then
                rm -f "$ONFILE"
                echo "Clicking OFF"
            else
                touch "$ONFILE"
                echo "Clicking ON (every ${INTERVAL_SECONDS}s)"
            fi
            ;;
        "q")
            echo "Exiting."
            break
            ;;
    esac
done
