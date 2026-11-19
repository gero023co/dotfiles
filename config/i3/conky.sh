#!/bin/sh
# Conky widget inherited from XFCE, adapted for i3.
#
# - It is launched from the AUTOSTART section of ~/.config/i3/config with
#   exec_always, so it also restarts when i3 restarts (Super+Shift+r).
# - In i3 the window is created as 'override' (see Mike_TimeStats) because i3
#   raises floating windows above tiled ones.
# - conky-lower.py sends it to the bottom of the X stack: it stays behind the
#   windows and visible on every workspace, as on the XFCE desktop.

CONKY_CONF="$HOME/.config/conky/mike-timestats-conky/Mike_TimeStats"
LOWER="$HOME/.config/i3/conky-lower.py"

# Avoid duplicates if the script is relaunched or i3 is restarted.
pkill -x conky 2>/dev/null
sleep 0.3

# setsid: detach conky so it stays alive when this script exits.
setsid conky -c "$CONKY_CONF" >/dev/null 2>&1 &

# Lower the window as soon as it appears (waits up to 10 s).
exec python3 "$LOWER"
