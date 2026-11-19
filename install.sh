#!/usr/bin/env bash
# Dotfiles installer.
# Backs up anything that already exists and creates symlinks to the repo.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.dotfiles-backup-$STAMP"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!!\033[0m %s\n' "$*"; }

backup_item() {
    local dst="$1"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local rel="${dst#"$HOME"/}"
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$dst" "$BACKUP/$rel"
    fi
}

link_path() {
    local src="$1" dst="$2"
    backup_item "$dst"
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
}

log "Repo: $DOTFILES"
log "Backup of existing configurations: $BACKUP"

# --- Application configurations ------------------------------------------
for app in i3 polybar conky kitty rofi picom fastfetch cava btop skippy-xd touchegg; do
    [ -d "$DOTFILES/config/$app" ] || continue
    link_path "$DOTFILES/config/$app" "$HOME/.config/$app"
    log "Linked ~/.config/$app"
done

# --- Home dotfiles --------------------------------------------------------
for f in .xprofile .Xresources .bashrc .bash_profile .tmux.conf; do
    [ -f "$DOTFILES/home/$f" ] || continue
    link_path "$DOTFILES/home/$f" "$HOME/$f"
    log "Linked ~/$f"
done

# --- Wallpaper ------------------------------------------------------------
mkdir -p "$HOME/.local/share/wallpapers"
for img in "$DOTFILES"/wallpapers/*; do
    [ -f "$img" ] || continue
    cp -f "$img" "$HOME/.local/share/wallpapers/"
    log "Copied wallpaper: $(basename "$img")"
done

# --- Included fonts (Feather, required for icons) -------------------------
mkdir -p "$HOME/.local/share/fonts"
for font in "$DOTFILES"/fonts/*.ttf; do
    [ -f "$font" ] || continue
    cp -f "$font" "$HOME/.local/share/fonts/"
    log "Copied font: $(basename "$font")"
done
command -v fc-cache >/dev/null && fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true

# --- Apply wallpaper if an X session is available -------------------------
if [ -n "${DISPLAY:-}" ] && command -v feh >/dev/null; then
    "$HOME/.config/i3/wallpaper.sh" 2>/dev/null || true
fi

# --- Check dependencies ---------------------------------------------------
missing=()
for cmd in i3 polybar picom conky kitty rofi feh fastfetch python3 pactl curl; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if ((${#missing[@]})); then
    warn "Missing commands: ${missing[*]}"
    warn "On Arch: sudo pacman -S --needed i3-wm polybar picom conky kitty rofi feh fastfetch python libpulse curl libx11 libnotify playerctl"
else
    log "Main dependencies found."
fi

cat <<EOF

Done. Next steps:
  1. Read README.md (dependencies, keybindings, and Conky configuration).
  2. Replace YOUR_CITY in ~/.config/conky/mike-timestats-conky/Mike_TimeStats.
  3. Restart i3 with Super+Shift+r (or log out and back in).
  4. If fonts are missing: ttf-firacode-nerd, ttf-iosevka-nerd, and the Feather
     font already included in fonts/.
EOF
