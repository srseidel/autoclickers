# autoclickers

Small macOS mouse-automation scripts: a mouse jiggler, a grid clicker, a
coordinate finder, and a panic "stop all" button. Hotkeys are wired up with
[skhd](https://github.com/koekeishiya/skhd) from a plain-text config.

> ## ⚠️ Known issue: hotkeys currently DO NOT work
>
> The scripts themselves run fine (start them from Terminal). The **skhd
> hotkeys are not functional** right now, and it's a macOS security limitation,
> not a bug in these scripts.
>
> **What's happening:** skhd needs **Accessibility** and **Input Monitoring**
> permission to capture global hotkeys. To grant those, macOS makes you pick the
> skhd binary in System Settings → Privacy & Security. The binary lives at
> `/opt/homebrew/bin/skhd`, but **`/opt` carries the macOS `hidden` filesystem
> flag** (Apple sets this on system dirs). Finder's file picker obeys that flag
> and refuses to show `/opt`, so we cannot navigate to or select the binary in
> the permission dialog — and System Settings' search only matches *setting
> names*, not files, so searching "skhd" finds nothing either.
>
> **Net effect:** skhd can't be granted the permission it needs, so the hotkeys
> don't fire. The intended workaround (`⌘⇧G` "Go to Folder" in the picker, or
> letting a keypress trigger the system prompt) is documented under
> [skhd service & permissions](#skhd-service--permissions) — but on this machine
> it hasn't succeeded yet, so **for now, launch the scripts manually** (see
> [Scripts](#scripts)) rather than via hotkey.

## Requirements

```sh
brew install cliclick                      # moves/clicks the mouse
brew install koekeishiya/formulae/skhd     # global hotkeys (optional)
```

Both the hotkey daemon and cliclick need **Accessibility** permission (and skhd
also needs **Input Monitoring**): System Settings → Privacy & Security. See
[skhd service & permissions](#skhd-service--permissions) below for how to grant
them — the app is not searchable in the picker and has to be added a specific way.

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
| `click_here_toggle.sh` | Left-click wherever the cursor is, once every second, while enabled. Runs in Terminal — press [space] to start/stop, [q] to quit. |
| `coords.sh` | Live cursor-position tracker — hover a spot to read its `x,y`. |
| `stop_all.sh` | Panic button — kills every clicker/jiggler and clears pidfiles. |
| `list_privileges.sh` | Read-only audit — lists apps with Accessibility, Input Monitoring, Screen Recording, or Full Disk Access. |

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
| ⌃⌥⌘ + J (Control-Option-Command-J) | toggle mouse jiggler |
| ⌃⌥⌘ + G (Control-Option-Command-G) | toggle grid clicker |
| ⌃⌥⌘ + . (Control-Option-Command-period) | stop everything |

`click_here_toggle.sh` has no hotkey — it's interactive (reads [space]/[q] from
its own Terminal window), so run it directly: `./click_here_toggle.sh`.

In the `skhdrc` config the Option (⌥) key is written as the keyword `alt` —
that's skhd's name for it, not the PC Alt key. Change a hotkey by editing
`~/.config/skhd/skhdrc`, then `skhd --reload`.

## skhd service & permissions

The hotkeys don't work until skhd is (a) running as a service and (b) granted
**Accessibility** *and* **Input Monitoring**. To detect a global hotkey, skhd
has to watch keystrokes system-wide — that's what those two permissions allow.

### Start / restart / check the service

```sh
skhd --start-service      # start the background hotkey daemon
skhd --restart-service    # restart it (run after granting permissions or editing skhdrc)
skhd --reload             # reload skhdrc without a full restart
launchctl list | grep skhd    # check it's running (a "0" exit code = healthy)
```

The easiest way to grant permissions: after `--start-service`, just **press a
hotkey** (e.g. ⌃⌥⌘J). macOS pops its own "skhd would like to control this
computer" prompt, which adds skhd to the right list automatically. Then
`skhd --restart-service` and test again.

### Adding skhd manually (if no prompt appears)

The skhd binary lives at `/opt/homebrew/bin/skhd`. **Finder hides `/opt`**, so
you can't browse to it in the file picker, and the System Settings search box
only searches *setting names*, not files on disk — which is why searching
"skhd" finds nothing. Add it like this:

1. In **Accessibility** (and again in **Input Monitoring**), click **`+`**.
2. In the file-picker dialog, press **⌘ ⇧ G** (Command-Shift-G).
3. Paste `/opt/homebrew/bin/skhd` and press Return, then **Open**.
4. Toggle it **on** in both panes, then `skhd --restart-service`.

### Why the shell commands (not just the GUI)

macOS deliberately hides system paths like `/opt` from Finder and the permission
picker, and its Settings search doesn't index files — so there's no pure
point-and-click way to locate the skhd binary. The `skhd --*-service` commands
are also the officially supported way to manage the daemon (it's a launchd
service, not an app you double-click), so there's no GUI equivalent for
starting/stopping it. Hence the terminal steps.

### Removing skhd's permissions / uninstalling the daemon

To revoke access or clean up:

```sh
skhd --stop-service                              # stop the background daemon
```

Then remove the permission entries in the GUI:

- System Settings → Privacy & Security → **Accessibility** → select **skhd** → click **`–`**
- System Settings → Privacy & Security → **Input Monitoring** → select **skhd** → click **`–`**

Or reset skhd's permission entries from the terminal (macOS re-prompts next time):

```sh
tccutil reset Accessibility com.koekeishiya.skhd
tccutil reset ListenEvent com.koekeishiya.skhd     # "Input Monitoring" in the GUI
```

To remove skhd entirely:

```sh
skhd --stop-service
brew uninstall skhd
rm -f ~/.config/skhd/skhdrc      # optional: delete the hotkey config
```

### Auditing what has these privileges

Accessibility, Input Monitoring, Screen Recording, and Full Disk Access are the
most powerful permissions on macOS — anything holding them can watch your
keystrokes or control the machine. To see everything that currently has them:

```sh
./list_privileges.sh    # read-only; prompts for sudo to read the system database
```

It reads Apple's TCC database and changes nothing. Note on how macOS works here:

- **Granting** one of these is **GUI-only by design** — there is no `sudo`/CLI
  command to *add* an app to Accessibility or Input Monitoring. Apple blocks it
  so software can't self-grant keystroke access; a human must click the toggle.
- **Removing** one *is* scriptable via Apple's built-in `tccutil reset`
  (see the skhd example above) — taking a privilege away is safe, so it's allowed.
- `tccutil` is Apple's own signed tool (`/usr/bin/tccutil`), not third-party.

## Also included

`mouse_jiggler.applescript` — the original AppleScript version of the jiggler,
runnable from Script Editor without skhd.
