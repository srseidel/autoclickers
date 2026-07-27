#!/bin/bash
# ============================================================
# Mouse Jiggler (toggle) — run once to START, again to STOP
# ============================================================
# Requires cliclick:   brew install cliclick
# ============================================================

# ===================== SETTINGS =============================
# Starting position in pixels. Use "center" to auto-center.
START_X="center"
START_Y="center"

MOVE_DISTANCE=100        # how far it moves back and forth (pixels)
INTERVAL_SECONDS=5       # seconds between each move
MOVE_DIRECTION="horizontal"   # "horizontal" or "vertical"
# ============================================================

CLICLICK="$(command -v cliclick || echo /opt/homebrew/bin/cliclick)"
PIDFILE="/tmp/mouse_jiggler.pid"

notify() { osascript -e "display notification \"$1\" with title \"Mouse Jiggler\""; }

# ---- If already running, this press STOPS it ----
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    notify "Stopped"
    exit 0
fi

# ---- Otherwise, START it ----
if [ ! -x "$CLICLICK" ]; then
    notify "cliclick not found — run: brew install cliclick"
    exit 1
fi

# Screen center via system_profiler-free method (uses AppleScript)
read SCREEN_W SCREEN_H < <(osascript -e 'tell application "Finder" to get bounds of window of desktop' \
    | awk -F', ' '{print $3, $4}')
CENTER_X=$((SCREEN_W / 2))
CENTER_Y=$((SCREEN_H / 2))

[ "$START_X" = "center" ] && BASE_X=$CENTER_X || BASE_X=$START_X
[ "$START_Y" = "center" ] && BASE_Y=$CENTER_Y || BASE_Y=$START_Y

if [ "$MOVE_DIRECTION" = "horizontal" ]; then
    B_X=$((BASE_X + MOVE_DISTANCE)); B_Y=$BASE_Y
else
    B_X=$BASE_X; B_Y=$((BASE_Y + MOVE_DISTANCE))
fi

# Background loop that bounces the mouse
(
    at_a=1
    while true; do
        if [ "$at_a" -eq 1 ]; then
            "$CLICLICK" m:$B_X,$B_Y; at_a=0
        else
            "$CLICLICK" m:$BASE_X,$BASE_Y; at_a=1
        fi
        sleep "$INTERVAL_SECONDS"
    done
) &

echo $! > "$PIDFILE"
notify "Started"
exit 0
