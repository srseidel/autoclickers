#!/bin/bash
# ============================================================
# Installer for autoclickers
# ------------------------------------------------------------
# Usage:
#   ./install.sh                 # install scripts to ~/bin
#   ./install.sh /usr/local/bin  # install to a different dir
#   ./install.sh --no-hotkeys    # skip skhd config
#   ./install.sh --uninstall     # remove scripts + restore skhdrc backup
#
# What it does:
#   1. Copies the *.sh scripts to the target dir (default ~/bin)
#   2. Makes them executable
#   3. Installs the skhd hotkey config (unless --no-hotkeys)
# ============================================================

set -euo pipefail

# ---- Resolve where this script lives (the repo dir) ----
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- Parse args ----
BIN_DIR="$HOME/bin"
WANT_HOTKEYS=1
UNINSTALL=0
for arg in "$@"; do
    case "$arg" in
        --no-hotkeys) WANT_HOTKEYS=0 ;;
        --uninstall)  UNINSTALL=1 ;;
        -*)           echo "Unknown option: $arg" >&2; exit 1 ;;
        *)            BIN_DIR="$arg" ;;
    esac
done

# The scripts to install (coords is a helper, still handy to have)
SCRIPTS=(
    coords.sh
    mouse_jiggler_toggle.sh
    grid_clicker.sh
    stop_all.sh
)

# ---- Uninstall mode: remove copied scripts, restore skhdrc backup ----
if [ "$UNINSTALL" -eq 1 ]; then
    echo "==> Uninstalling from: $BIN_DIR"
    # Stop anything currently running before removing its script
    [ -x "$BIN_DIR/stop_all.sh" ] && "$BIN_DIR/stop_all.sh" >/dev/null 2>&1 || true
    for s in "${SCRIPTS[@]}"; do
        if [ -e "$BIN_DIR/$s" ]; then
            rm -f "$BIN_DIR/$s"
            echo "    removed $s"
        fi
    done

    SKHD_DIR="$HOME/.config/skhd"
    if [ -f "$SKHD_DIR/skhdrc" ]; then
        # Restore the most recent backup if one exists, else just remove ours
        LATEST_BAK="$(ls -t "$SKHD_DIR"/skhdrc.bak.* 2>/dev/null | head -n1 || true)"
        if [ -n "$LATEST_BAK" ]; then
            mv "$LATEST_BAK" "$SKHD_DIR/skhdrc"
            echo "    restored skhdrc from backup ($(basename "$LATEST_BAK"))"
        else
            rm -f "$SKHD_DIR/skhdrc"
            echo "    removed skhdrc (no backup found)"
        fi
        command -v skhd >/dev/null 2>&1 && skhd --reload 2>/dev/null || true
    fi
    echo "==> Uninstall done."
    exit 0
fi

echo "==> Installing scripts to: $BIN_DIR"
mkdir -p "$BIN_DIR"
for s in "${SCRIPTS[@]}"; do
    cp "$SRC_DIR/$s" "$BIN_DIR/$s"
    chmod +x "$BIN_DIR/$s"
    echo "    installed $s"
done

# ---- Warn if the target dir isn't on PATH ----
case ":$PATH:" in
    *":$BIN_DIR:"*) : ;;
    *) echo "    note: $BIN_DIR is not on your PATH (fine for hotkeys, but you can't call them by name)" ;;
esac

# ---- cliclick dependency check ----
if ! command -v cliclick >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/cliclick ]; then
    echo "==> WARNING: cliclick not found. Install it with:  brew install cliclick"
fi

# ---- Hotkeys via skhd ----
if [ "$WANT_HOTKEYS" -eq 1 ]; then
    echo "==> Setting up skhd hotkeys"
    if ! command -v skhd >/dev/null 2>&1; then
        echo "    skhd not installed. Install it with:"
        echo "        brew install koekeishiya/formulae/skhd"
        echo "    then re-run:  ./install.sh $BIN_DIR"
    else
        SKHD_DIR="$HOME/.config/skhd"
        mkdir -p "$SKHD_DIR"
        # Back up any existing config
        if [ -f "$SKHD_DIR/skhdrc" ]; then
            cp "$SKHD_DIR/skhdrc" "$SKHD_DIR/skhdrc.bak.$(date +%s)"
            echo "    backed up existing skhdrc"
        fi
        # Substitute {{BIN}} with the real install dir
        sed "s|{{BIN}}|$BIN_DIR|g" "$SRC_DIR/skhdrc" > "$SKHD_DIR/skhdrc"
        echo "    wrote $SKHD_DIR/skhdrc"
        # Start (or restart) the skhd service
        skhd --reload 2>/dev/null || skhd --start-service 2>/dev/null || true
        echo "    hotkeys active (edit $SKHD_DIR/skhdrc then run: skhd --reload)"
        echo
        echo "    NOTE: grant Accessibility to skhd:"
        echo "      System Settings > Privacy & Security > Accessibility > add skhd"
    fi
fi

echo "==> Done."
