#!/usr/bin/env bash
# Start the Karabiner virtual HID daemon (macOS) alongside kanata.
# On Linux, kanata talks to uinput directly; run it without the daemon:
#   kanata -c ~/.config/kanata/kanata.kbd

set -euo pipefail

CONFIG="${KANATA_CONFIG:-$HOME/.config/kanata/kanata.kbd}"
KANATA="${KANATA_BIN:-}"
if [[ -z "$KANATA" ]]; then
    # Prefer a locally built kanata, fall back to whatever is on PATH.
    if [[ -x "$HOME/dev/kanata/target/release/kanata" ]]; then
        KANATA="$HOME/dev/kanata/target/release/kanata"
    else
        KANATA="kanata"
    fi
fi
DAEMON='/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'

if [[ "$(uname -s)" == "Darwin" && -x "$DAEMON" ]]; then
    "$DAEMON" &
fi

exec "$KANATA" -c "$CONFIG"
