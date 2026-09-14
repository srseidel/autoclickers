#!/bin/bash
# ============================================================
# Grid Clicker (toggle) — clicks a list of points in sequence
# Run once to START, run again to STOP.
# Requires cliclick:  brew install cliclick
# ============================================================

# ===================== SETTINGS =============================
# One "x,y" per line. Find coordinates with ~/bin/coords.sh
# Clicks them top-to-bottom, then loops back to the first.
POINTS=(
    "509,396"
    "675,391"
    "835,388"
    "990,392"
    "508,522"
    "670,528"
    "833,527"
    "990,527"
    "512,655"
    "674,655"
    "836,659"
    "990,658"
)

INTERVAL_SECONDS=30      # seconds between each click
# ============================================================

CLICLICK="$(command -v cliclick || echo /opt/homebrew/bin/cliclick)"
PIDFILE="/tmp/grid_clicker.pid"

notify() { osascript -e "display notification \"$1\" with title \"Grid Clicker\""; }

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

# Background loop: click each point in turn, waiting between clicks
(
    i=0
    n=${#POINTS[@]}
    while true; do
        xy="${POINTS[$i]}"
        "$CLICLICK" "c:${xy}"
        i=$(((i + 1) % n))
        sleep "$INTERVAL_SECONDS"
    done
) &

echo $! > "$PIDFILE"
notify "Started"
exit 0
