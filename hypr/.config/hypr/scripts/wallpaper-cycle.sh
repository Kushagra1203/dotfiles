#!/bin/bash

WALLPAPER_DIR="$HOME/Wallpaper"
INTERVAL=1800
LOGFILE="$HOME/wallpaper-change.log"

# Start daemon
killall swww-daemon 2>/dev/null
swww-daemon &>/dev/null &
sleep 2

# Create list of VALID images only
imgs=()
while IFS= read -r f; do
    [[ "$(basename "$f")" =~ ^\._ ]] && continue
    if file "$f" | grep -qiE "JPEG|PNG"; then
        imgs+=("$f")
    else
        echo "$(date): Skipped invalid: $f" >> "$LOGFILE"
    fi
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))

if [ ${#imgs[@]} -eq 0 ]; then
    echo "No valid images found."
    exit 1
fi

prev=""

while true; do
    while true; do
        img="${imgs[RANDOM % ${#imgs[@]}]}"
        [[ "$img" != "$prev" ]] && break
    done

    prev="$img"
    echo "$(date): Setting $img" >> "$LOGFILE"

    # Apply wallpaper
    swww img "$img" --transition-type fade --transition-duration 2

    # ---- MATERIAL YOU THEME UPDATE ----
    matugen image "$img"

    # Hot reload Hyprland
    hyprctl reload

    # Hot reload Kitty colors
    kitty @ set-colors --all ~/.config/kitty/kitty-theme.conf

    # ----------------------------------------

    # Hyprpanel auto-theme stays untouched
    jq --arg wp "$img" '.["wallpaper.image"] = $wp' \
        ~/.config/hyprpanel/config.json > /tmp/hp.json

mv /tmp/hp.json ~/.config/hyprpanel/config.json
    pkill -f hyprpanel
    hyprpanel &>/dev/null &

    sleep "$INTERVAL"
done
