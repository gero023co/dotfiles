#!/usr/bin/env bash
# Launch Polybar with the "forest" theme.
# Usage: ~/.config/polybar/launch.sh [--forest]

dir="$HOME/.config/polybar"
style="forest"

# Terminate previous instances (ignore zombies).
killall -q polybar 2>/dev/null

bar_running() {
    local pid state
    for pid in $(pgrep -u "$UID" -x polybar); do
        state=$(ps -o stat= -p "$pid" 2>/dev/null)
        case "$state" in
            Z*) ;;
            *) return 0 ;;
        esac
    done
    return 1
}

while bar_running; do sleep 1; done

# Wait for PipeWire/PulseAudio: if Polybar starts too early, the internal/alsa
# module cannot connect and the volume module is missing until the bar restarts.
wait_for_audio() {
    local i
    for ((i = 0; i < 40; i++)); do
        if pactl info >/dev/null 2>&1 && pactl list short sinks 2>/dev/null | grep -q .; then
            return 0
        fi
        sleep 0.5
    done
}

wait_for_audio

polybar -q main -c "$dir/$style/config.ini" &
