# autoclickers

Small macOS mouse-automation scripts: a mouse jiggler, a grid clicker, a
coordinate finder, and a panic "stop all" button. Hotkeys are wired up with
[skhd](https://github.com/koekeishiya/skhd) from a plain-text config.

## Requirements

```sh
brew install cliclick                      # moves/clicks the mouse
brew install koekeishiya/formulae/skhd     # global hotkeys (optional)
```

Both the hotkey daemon and cliclick need **Accessibility** permission:
System Settings → Privacy & Security → Accessibility.

## Install

```sh
./install.sh                 # copy scripts to ~/bin + install hotkeys
./install.sh /usr/local/bin  # copy to a different dir
./install.sh --no-hotkeys    # copy scripts only, skip skhd
./install.sh --uninstall     # remove installed scripts + restore skhdrc backup
```

Uninstall stops anything running first, removes the copied scripts, and
restores the most recent `skhdrc` backup (or removes ours if there was none).
Pass the same target dir you installed to, e.g. `./install.sh --uninstall /usr/local/bin`.

## Scripts

| Script | What it does |
|---|---|
| `mouse_jiggler_toggle.sh` | Bounce the mouse back and forth. Run to start, run again to stop. |
| `grid_clicker.sh` | Click through a list of points, one every N seconds, looping. Toggle. |
| `coords.sh` | Live cursor-position tracker — hover a spot to read its `x,y`. |
| `stop_all.sh` | Panic button — kills every clicker/jiggler and clears pidfiles. |

Edit the `SETTINGS` block at the top of each script (start position, distance,
interval, grid points).

### Finding grid coordinates

```sh
~/bin/coords.sh   # move the mouse; note the numbers; Ctrl-C to quit
```

Paste the `"x,y"` values into the `POINTS` list in `grid_clicker.sh`.

## Hotkeys

Defined in [`skhdrc`](./skhdrc) (installed to `~/.config/skhd/skhdrc`):

| Hotkey | Action |
|---|---|
| `ctrl+alt+cmd + J` | toggle mouse jiggler |
| `ctrl+alt+cmd + G` | toggle grid clicker |
| `ctrl+alt+cmd + .` | stop everything |

Change a hotkey by editing `~/.config/skhd/skhdrc`, then `skhd --reload`.

## Also included

`mouse_jiggler.applescript` — the original AppleScript version of the jiggler,
runnable from Script Editor without skhd.
