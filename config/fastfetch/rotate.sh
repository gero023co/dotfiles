#!/bin/sh
# Rotate the fastfetch logo: a different image on every run.
# The images live in ~/.config/fastfetch/ (PNG with transparency, 512x512).
# The remaining options are still read from config.jsonc.

dir="$HOME/.config/fastfetch"
state="${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch-logo.state"
imgs="makima.png tomoko.png ushanka.png zerotwo.png"

cur=""
[ -r "$state" ] && cur=$(cat "$state")

# find the image after the last used one (and wrap around to the first)
next=""
found=""
for img in $imgs; do
	if [ -n "$found" ]; then
		next=$img
		break
	fi
	[ "$img" = "$cur" ] && found=1
done
[ -z "$next" ] && next=$(echo $imgs | cut -d' ' -f1)
[ -r "$dir/$next" ] || next=$(echo $imgs | cut -d' ' -f1)

printf '%s\n' "$next" > "$state"

# absolute path: prevents recursion if the user has "fastfetch" as a function/alias
exec /usr/bin/fastfetch --logo "$dir/$next" "$@"
