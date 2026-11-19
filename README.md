# Dotfiles — i3 + Polybar (Arch Linux)

Personal desktop configuration for **Arch Linux** with **i3 (X11)**, **Polybar**, **Picom**, **Conky**, **Kitty**, **Rofi**, **Fastfetch**, and a few extras. It is designed for a **1366×768** display, but it works on other resolutions by adjusting the wallpaper and the Conky position.

---

## Contents

- [Overview](#overview)
- [Repository structure](#repository-structure)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Configure Conky (manual position)](#configure-conky-manual-position)
- [i3 keybindings](#i3-keybindings)
- [Polybar and Rofi](#polybar-and-rofi)
- [Quick customization](#quick-customization)
- [Notes and known issues](#notes-and-known-issues)
- [Credits and license](#credits-and-license)

---

## Overview

| Component | Configuration |
|---|---|
| WM | i3 4.25 (X11), 7 px inner gaps, 2 px borders |
| Bar | Polybar, **forest** theme (34 px, top) |
| Compositor | Picom (rounded corners, no shadows or blur) |
| Widget | Conky **Mike TimeStats** (clock, date, weather) |
| Terminal | Kitty (FiraCode Nerd Font, 0.78 opacity) |
| Launcher / menu | Rofi (adi1090x type-3 theme, powermenu) |
| Wallpaper | `wallpapers/wallhaven-og6xg7_1366x768.png` with `feh` |
| System info | Fastfetch with rotating logos (4 PNG files) |
| Extras | Cava, Btop, Skippy-XD, Touchégg (optional) |

Main palette: background `#0b1114`, foreground `#d2dadf`, teal accent `#6ebbc5`, amber `#e68a33`.

---

## Repository structure

```text
dotfiles/
├── config/
│   ├── i3/                 # config, desktop scripts, conky, wallpaper
│   ├── polybar/            # launch.sh + complete forest theme
│   ├── conky/              # Mike_TimeStats
│   ├── kitty/              # kitty.conf
│   ├── rofi/               # config, launchers, powermenu, scripts
│   ├── picom/              # picom.conf
│   ├── fastfetch/          # config.jsonc, rotate.sh, 4 PNG files
│   ├── cava/               # config, themes, shaders
│   ├── btop/               # btop.conf
│   ├── skippy-xd/          # skippy-xd.rc
│   └── touchegg/           # touchegg.conf
├── home/                   # .xprofile, .Xresources, .bashrc, .bash_profile, .tmux.conf
├── wallpapers/             # wallpaper
├── fonts/                  # feather.ttf (Polybar/Rofi icons)
├── install.sh
└── README.md
```

`install.sh` creates **symlinks** from `~/.config/<app>` to the repository, so edits are made directly in the repo. It backs up existing files to `~/.dotfiles-backup-<date>` first.

---

## Dependencies

### Base (Arch Linux)

```bash
sudo pacman -S --needed \
  i3-wm polybar picom conky kitty rofi feh fastfetch \
  python libx11 libpulse libnotify playerctl curl \
  ttf-firacode-nerd ttf-iosevka-nerd papirus-icon-theme \
  i3lock xorg-setxkbmap network-manager-applet
```

| Package / command | Used for |
|---|---|
| `i3-wm` | Window manager |
| `polybar` | Top bar (`internal/*` modules) |
| `picom` | Compositor and rounded corners |
| `conky` | Clock/date/weather widget |
| `kitty` | Terminal |
| `rofi` | Application launcher and power menu |
| `feh` | Set the wallpaper |
| `fastfetch` | System information when opening a terminal |
| `python` | `conky-lower.py` and `i3-hidden.py` |
| `libx11` | `ctypes` support in `conky-lower.py` (lowers the Conky window) |
| `libpulse` | `pactl` for the volume keys |
| `libnotify` | `notify-send` in the update script |
| `playerctl` | Pause music before suspending (optional) |
| `curl` | Conky weather (`wttr.in`) |
| `ttf-firacode-nerd` | Kitty font |
| `ttf-iosevka-nerd` | Polybar and Rofi font |
| `papirus-icon-theme` | Rofi icons (`icon-theme: "Papirus"`) |
| `i3lock` | Lock the screen from the power menu |
| `xorg-setxkbmap` | Toggle the `latam`/`us` keyboard layout |
| `network-manager-applet` | Network applet (optional; commented out in i3) |

### Optional extras

```bash
# Official repositories
sudo pacman -S --needed cava btop dex xss-lock networkmanager-dmenu plank touchegg

# AUR (with yay/paru)
yay -S --needed skippy-xd-git bibata-cursor-git
```

| Package | Purpose |
|---|---|
| `cava` | Audio visualizer |
| `btop` | Resource monitor |
| `dex` | Runs autostart `.desktop` files; the i3 config calls it |
| `xss-lock` | Locks with i3lock on suspend; the i3 config calls it |
| `networkmanager-dmenu` | Network menu when clicking the Polybar network module |
| `plank` | Dock (not started by i3 by default) |
| `touchegg` | Touchpad gestures (3 fingers) |
| `skippy-xd-git` | Mission Control-style window overview |
| `bibata-cursor-git` | `Bibata-Modern-Ice` cursor used in `.xprofile` / `.Xresources` |

> **`dex` and `xss-lock`:** the i3 config runs them, but they were not installed on the original system. If you do not want them, comment out the corresponding `exec` lines in `config/i3/config`; if you install them, they will work.

### Fonts

| Font | Used for | Installation |
|---|---|---|
| FiraCode Nerd Font | Kitty | `ttf-firacode-nerd` |
| Iosevka Nerd Font | Polybar, Rofi | `ttf-iosevka-nerd` |
| Feather | Polybar/Rofi icons | included in `fonts/feather.ttf` |
| Anurati | Conky day title | manual (see below) |
| Nasalization | Conky date/time/weather | manual (see below) |

`install.sh` copies `feather.ttf` to `~/.local/share/fonts/` and runs `fc-cache`.  
Anurati and Nasalization are optional: if they are not installed, Conky falls back to the default font. They can be downloaded from Dafont:

- <https://www.dafont.com/anurati.font>
- <https://www.dafont.com/nasalization.font>

---

## Installation

### 1. Clone

```bash
git clone https://github.com/gero023co/dotfiles.git
cd dotfiles
```

### 2. Install

```bash
chmod +x install.sh
./install.sh
```

The script:

1. Backs up `~/.config/{i3,polybar,conky,kitty,rofi,picom,fastfetch,cava,btop,skippy-xd,touchegg}` and the home dotfiles to `~/.dotfiles-backup-<date>`.
2. Symlinks the configurations to the repository.
3. Copies the wallpaper to `~/.local/share/wallpapers/`.
4. Copies `feather.ttf` to `~/.local/share/fonts/` and refreshes the cache.
5. Applies the wallpaper if an X session is available.
6. Warns about missing commands.

### 3. Apply changes

```bash
i3-msg restart
# or Super+Shift+r
```

If you changed `.xprofile` (cursor) or the keyboard layout, **log out and back in** so LightDM/X loads it.

### Manual installation (without the script)

```bash
cp -r config/* ~/.config/
cp home/.xprofile home/.Xresources home/.bashrc home/.bash_profile home/.tmux.conf ~/
mkdir -p ~/.local/share/wallpapers
cp wallpapers/* ~/.local/share/wallpapers/
mkdir -p ~/.local/share/fonts
cp fonts/feather.ttf ~/.local/share/fonts/
fc-cache -f
```

Then restart i3. The wallpaper is applied by `~/.config/i3/wallpaper.sh` (already in the i3 autostart).

---

## Configure Conky (manual position)

**The Conky widget does not place itself automatically.** You must edit its file and adjust the position manually:

```text
~/.config/conky/mike-timestats-conky/Mike_TimeStats
```

Relevant block:

```lua
alignment = 'top_middle',   -- top_left, top_middle, top_right,
                            -- middle_left, middle_center, middle_right,
                            -- bottom_left, bottom_middle, bottom_right
gap_x = 0,                  -- horizontal offset in pixels
gap_y = 60,                 -- vertical offset in pixels
minimum_width = 800,
minimum_height = 300,
```

- To move it to the right: `alignment = 'top_right'` and `gap_x = 40`.
- To move it down: increase `gap_y`.
- To center it on another resolution: adjust `minimum_width` or use a positive/negative `gap_x`.
- On multi-monitor setups, Conky may need a different `gap_x` or a per-screen `alignment`.

### Weather city

The repository does not include a city. In `Mike_TimeStats`, `YOUR_CITY` appears in the `wttr.in` lines. Change it:

```bash
sed -i 's/YOUR_CITY/YourCity/g' ~/.config/conky/mike-timestats-conky/Mike_TimeStats
```

The weather requires `curl` and an internet connection. If it fails, the widget shows the `wttr.in` error text.

### How it is drawn in i3

- `conky.sh` launches Conky with `own_window_type = 'override'` when it detects `I3SOCK`.
- `conky-lower.py` lowers the window to the bottom of the X stack so it stays **behind the windows** and visible on every workspace.
- If the widget appears above the windows or does not appear:

```bash
pkill -x conky
~/.config/i3/conky.sh
```

- On XFCE the same file uses `own_window_type = 'desktop'`; the script detects i3 through `I3SOCK`.

---

## i3 keybindings

`$mod` = **Super** (Windows key). Bindings are defined in `config/i3/config`.

### Applications and system

| Shortcut | Action |
|---|---|
| `Super + Enter` | Open Kitty |
| `Super + Q` | Close the focused window |
| `Super + L` | Rofi launcher (`rofi -show drun`) |
| `Super + X` | Power menu (Rofi powermenu) |
| `Super + D` | Show/hide desktop (hides windows in the scratchpad) |
| `Super + C` | Toggle keyboard layout `latam` ↔ `us` |
| `Super + Shift + C` | Reload the i3 configuration |
| `Super + Shift + R` | Restart i3 while keeping windows |
| `Super + Shift + E` | Exit i3 (with `i3-nagbar` confirmation) |

### Windows

| Shortcut | Action |
|---|---|
| `Super + ←/↓/↑/→` | Focus the window in that direction |
| `Super + Shift + ←/↓/↑/→` | Move the window in that direction |
| `Super + H` | Split horizontally |
| `Super + V` | Split vertically |
| `Super + F` | Fullscreen |
| `Super + S` | Stacking layout |
| `Super + W` | Tabbed layout |
| `Super + E` | Toggle split/stacking |
| `Super + Shift + Space` | Toggle floating/tiled |
| `Super + Space` | Toggle focus between tiled and floating |
| `Super + A` | Focus the parent container |
| `Super + R` | Enter resize mode |
| `Super + left mouse button` | Drag a floating window |
| `Super + right mouse button` | Resize a floating window |

### Workspaces

| Shortcut | Action |
|---|---|
| `Super + 1…9, 0` | Go to workspace 1…10 |
| `Super + Shift + 1…9, 0` | Move the focused window to workspace 1…10 |

### Resize mode (`Super + R`)

| Key | Action |
|---|---|
| `J` / `←` | Shrink width |
| `K` / `↓` | Grow height |
| `L` / `↑` | Shrink height |
| `ntilde` / `→` | Grow width |
| `Enter` / `Esc` / `Super + R` | Exit resize mode |

### Media keys

| Shortcut | Action |
|---|---|
| `XF86AudioRaiseVolume` | Increase volume by 10% |
| `XF86AudioLowerVolume` | Decrease volume by 10% |
| `XF86AudioMute` | Mute output |
| `XF86AudioMicMute` | Mute microphone |

---

## Polybar and Rofi

### Polybar

The bar is launched with:

```bash
~/.config/polybar/launch.sh --forest
```

Active modules:

- **Left:** launcher, separator, i3 workspaces, CPU, memory.
- **Center:** date and time.
- **Right:** battery, network, separator, volume, brightness, system menu.

Clicks:

| Area | Action |
|---|---|
| Arch icon (left) | Open Rofi (`scripts/launcher.sh`) |
| Right-click on the icon | Change color style (`scripts/style-switch.sh`) |
| Power icon (right) | Rofi power menu |
| Network module | `networkmanager_dmenu` (if installed) |

Only the **forest** theme is included. The other themes from `adi1090x/polybar-themes` are not in this repository.

### Rofi

- `config.rasi` uses the `launchers/type-3/style-3.rasi` style.
- The power menu is `rofi/scripts/powermenu.sh` and uses `powermenu/type-3/style-3.rasi`.
- Available colors are in `rofi/colors/` (`onedark.rasi` is active; `catppuccin.rasi` is also included).
- Icons: `Papirus` (install `papirus-icon-theme` or change `icon-theme`).

---

## Quick customization

| What to change | Where |
|---|---|
| Wallpaper | `config/i3/wallpaper.sh` or replace the file in `wallpapers/` |
| Polybar colors | `config/polybar/forest/colors.ini` |
| Kitty colors | `config/kitty/kitty.conf` |
| Rofi colors | `config/rofi/colors/onedark.rasi` and `shared/colors.rasi` |
| i3 gaps/borders | `gaps inner`, `new_window`, `client.*` in `config/i3/config` |
| Keyboard layout | `config/i3/toggle-layout.sh` (`SYSTEM="latam"`, `US="us"`) |
| Conky position | `alignment`, `gap_x`, `gap_y` in `Mike_TimeStats` |
| Weather city | replace `YOUR_CITY` in `Mike_TimeStats` |
| Fastfetch logos | replace the `.png` files in `config/fastfetch/` and edit `rotate.sh` |

---

## Notes and known issues

- **Conky requires manual position adjustment** (see the section above). There is no dynamic auto-centering per resolution.
- **`dex` and `xss-lock`** are called from i3 but are not mandatory. If they are not installed, i3 writes a warning to `~/.xsession-errors`.
- **Brightness:** Polybar's `internal/backlight` module needs a backlight device. On a desktop without a laptop panel it may not appear.
- **Battery:** the module only appears if a battery exists.
- **Network:** the module click uses `networkmanager_dmenu`; without that package the click does nothing. The bar uses `internal/network`, so the applet is not required.
- **Bibata cursor:** `.xprofile` and `.Xresources` reference it. If it is not installed, X uses the default cursor; install `bibata-cursor-git` or change the name.
- **Resolution:** the wallpaper is 1366×768 and the Rofi theme uses `width: 1366px` / `height: 768px`; adjust those values in `launchers/type-3/style-3.rasi` for other resolutions.
- **Picom:** `corner-radius` requires a Picom version with rounded-corner support. If your version does not accept it, remove that line.
- **Polybar and audio:** `launch.sh` waits for PipeWire/PulseAudio before starting the bar so the volume module can connect.

---

## Credits and license

- Polybar **forest** theme and Rofi themes: [adi1090x](https://github.com/adi1090x) (`polybar-themes`, `rofi`).
- **Mike TimeStats** widget: MikeDevQH, GPLv3.
- `checkupdates`: Kyle Keen (GPLv2).
- **Feather** font: [feathericons](https://github.com/feathericons/feather), MIT.
- Wallpaper: Wallhaven (`wallhaven-og6xg7`).
- Fastfetch images: included as part of the visual theme.

The original content of this repository is distributed under **GPL-3.0** to remain compatible with the included third-party configurations. See `LICENSE`.
