#!/bin/sh
# Wallpaper for the i3 session.
# install.sh copies the image to ~/.local/share/wallpapers/.
# If you use a different path, change WALLPAPER.

WALLPAPER="$HOME/.local/share/wallpapers/wallhaven-og6xg7_1366x768.png"

[ -f "$WALLPAPER" ] || exit 0
exec feh --no-fehbg --bg-fill "$WALLPAPER"
