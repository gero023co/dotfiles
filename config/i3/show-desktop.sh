#!/usr/bin/env bash
# Toggles "show desktop" per workspace:
#   1st press -> hides the windows on the current workspace (scratchpad)
#   2nd press -> restores the hidden windows of THAT workspace, tiled
#                (not floating), respecting the Super+h / Super+v split.
# The daemon ~/.config/i3/i3-hidden.py daemon restores automatically when a new
# window is opened on the same workspace (without Super+D).
# Usage: bindsym $mod+d exec --no-startup-id ~/.config/i3/show-desktop.sh

exec ~/.config/i3/i3-hidden.py toggle
