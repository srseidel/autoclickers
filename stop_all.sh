#!/bin/bash
# ============================================================
# Panic button — stops ALL jiggler/clicker scripts immediately.
# Safe to run anytime, even if nothing is running.
# ============================================================

pkill -f 'grid_clicker.sh'
pkill -f 'mouse_jiggler_toggle.sh'
pkill -f 'mouse_jiggler.sh'
pkill -f 'click_here_toggle.sh'
rm -f /tmp/grid_clicker.pid /tmp/mouse_jiggler.pid /tmp/click_here.on

osascript -e 'display notification "All auto-clickers stopped" with title "Stop All"'
exit 0
