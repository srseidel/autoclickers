#!/bin/bash
# ============================================================
# Mouse Mover — moves the cursor (no clicks) between the center
# of the screen and a spot a bit to the right, once every
# 5 minutes, while enabled. Run it, then use the keys below:
#   [space]  start/stop moving
#   [q]      quit the script
# Requires cliclick:  brew install cliclick
# ============================================================

# ===================== SETTINGS =============================
INTERVAL_SECONDS=300    # seconds between each move (300 = 5 min)
OFFSET_X=200            # how far right of center to move, in pixels
# ============================================================

CLICLICK="$(command -v cliclick || echo /opt/homebrew/bin/cliclick)"
ONFILE="/tmp/mouse_mover.on"

if [ ! -x "$CLICLICK" ]; then
    echo "cliclick not found — run: brew install cliclick" >&2
    exit 1
fi

# Main screen size from Finder's desktop bounds, e.g. "0, 0, 1920, 1080"
BOUNDS="$(osascript -e 'tell application "Finder" to get bounds of window of desktop' 2>/dev/null)"
SCREEN_W="$(echo "$BOUNDS" | awk -F', ' '{print $3}')"
SCREEN_H="$(echo "$BOUNDS" | awk -F', ' '{print $4}')"
if [ -z "$SCREEN_W" ] || [ -z "$SCREEN_H" ]; then
    echo "Could not read screen size from Finder" >&2
    exit 1
fi
CENTER_X=$((SCREEN_W / 2))
CENTER_Y=$((SCREEN_H / 2))
RIGHT_X=$((CENTER_X + OFFSET_X))

rm -f "$ONFILE"
cleanup() { rm -f "$ONFILE"; }
trap cleanup EXIT

# Background loop: while ONFILE exists, start at center then alternate
# center <-> right every INTERVAL_SECONDS. Ticks once a second so
# toggling on/off takes effect right away.
(
    was_on=0
    at_right=0
    elapsed=0
    while true; do
        if [ -f "$ONFILE" ]; then
            if [ "$was_on" -eq 0 ]; then
                "$CLICLICK" m:"$CENTER_X","$CENTER_Y"
                was_on=1; at_right=0; elapsed=0
            elif [ "$elapsed" -ge "$INTERVAL_SECONDS" ]; then
                if [ "$at_right" -eq 1 ]; then
                    "$CLICLICK" m:"$CENTER_X","$CENTER_Y"; at_right=0
                else
                    "$CLICLICK" m:"$RIGHT_X","$CENTER_Y"; at_right=1
                fi
                elapsed=0
            fi
            elapsed=$((elapsed + 1))
        else
            was_on=0
        fi
        sleep 1
    done
) &
LOOP_PID=$!
trap 'cleanup; kill "$LOOP_PID" 2>/dev/null' EXIT

echo "Moving OFF. Press [space] to start/stop, [q] to quit."
while true; do
    IFS= read -rsn1 key
    case "$key" in
        " ")
            if [ -f "$ONFILE" ]; then
                rm -f "$ONFILE"
                echo "Moving OFF"
            else
                touch "$ONFILE"
                echo "Moving ON (center <-> +${OFFSET_X}px every ${INTERVAL_SECONDS}s)"
            fi
            ;;
        "q")
            echo "Exiting."
            break
            ;;
    esac
done
