#!/bin/bash
# Live cursor-coordinate tracker. Move your mouse; press Ctrl-C to quit.
# Prints the (x,y) under the cursor twice a second.
CLICLICK="$(command -v cliclick || echo /opt/homebrew/bin/cliclick)"
echo "Move your mouse to each spot you want. Press Ctrl-C when done."
while true; do
    printf "\r  cursor at: %-20s" "$("$CLICLICK" p)"
    sleep 0.5
done
