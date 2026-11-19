#!/usr/bin/env bash
# Toggles the keyboard layout between the system layout (latam) and us.
# Shortcut: bindsym $mod+c exec --no-startup-id ~/.config/i3/toggle-layout.sh

SYSTEM="latam"   # system layout (see /etc/X11/xorg.conf.d/00-keyboard.conf)
US="us"

CURRENT=$(setxkbmap -query | awk -F: '/layout/ {gsub(/ /, "", $2); print $2; exit}')

if [ "$CURRENT" = "$US" ]; then
    setxkbmap "$SYSTEM"
else
    setxkbmap "$US"
fi
