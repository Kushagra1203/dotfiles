#!/bin/bash

# --- DEBUGGING ---
LOG_FILE="/tmp/wallust_debug.log"
echo "--- Run at $(date) ---" > "$LOG_FILE"

# --- CONFIGURATION ---
target_opacity=0.85
anim_speed=0.03

# FIX: Get absolute path to image so wallust never loses it
img_path=$(realpath "$1")
echo "Target Image: $img_path" >> "$LOG_FILE"

if [ -z "$1" ]; then
    echo "Error: No image provided" >> "$LOG_FILE"
    exit 1
fi

# ----------------------------------------------------- 
# HELPER: FADE ANIMATION
# ----------------------------------------------------- 
animate_opacity() {
    direction=$1 
    
    if [ "$direction" == "out" ]; then
        for i in $(seq "$target_opacity" -0.1 0); do
            hyprctl keyword decoration:active_opacity "$i"
            hyprctl keyword decoration:inactive_opacity "$i"
            sleep "$anim_speed"
        done
        # FIX: Ensure it hits absolute zero transparency
        hyprctl keyword decoration:active_opacity 0
        hyprctl keyword decoration:inactive_opacity 0
        hyprctl keyword decoration:blur:enabled false
        
    elif [ "$direction" == "in" ]; then
        hyprctl keyword decoration:blur:enabled true
        for i in $(seq 0 0.1 "$target_opacity"); do
            hyprctl keyword decoration:active_opacity "$i"
            hyprctl keyword decoration:inactive_opacity "$i"
            sleep "$anim_speed"
        done
        # FIX: Ensure it hits exactly the target opacity
        hyprctl keyword decoration:active_opacity "$target_opacity"
        hyprctl keyword decoration:inactive_opacity "$target_opacity"
    fi
}

# 1. MONITOR INFO & COORDINATES
mon_info=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true)')
width=$(echo "$mon_info" | jq -r '.width')
height=$(echo "$mon_info" | jq -r '.height')
rand_x=$(shuf -i 0-"$width" -n 1)
rand_y=$(shuf -i 0-"$height" -n 1)

# 2. FADE OUT
pkill -f hyprpanel
animate_opacity "out"

# ZEN RESTART
if pgrep -x "zen" > /dev/null; then
    ZEN_WS=$(hyprctl clients -j | jq -r '.[] | select(.class == "zen") | .workspace.id' | head -n 1)
    hyprctl keyword windowrulev2 "workspace $ZEN_WS silent, class:^(zen)$"
    pkill -x zen
    /home/kushagra/.local/share/zen-browser/zen &
    (sleep 5 && hyprctl keyword windowrulev2 "unset, class:^(zen)$") &
fi

hyprctl keyword decoration:fullscreen_opacity 0

# 3. APPLY WALLPAPER (SWWW)
swww img "$img_path" \
    --transition-type grow \
    --transition-pos "$rand_x,$rand_y" \
    --transition-duration 2 \
    --transition-fps 60

# --- PROCESS UPDATES (WALLUST) ---
ln -sf "$img_path" "$HOME/.config/hypr/current_wallpaper"

# THE FIX: HARDCODED CARGO PATH
WALLUST_BIN="$HOME/.cargo/bin/wallust"

if [ -f "$WALLUST_BIN" ]; then
    echo "Wallust found at: $WALLUST_BIN" >> "$LOG_FILE"
    $WALLUST_BIN run "$img_path" >> "$LOG_FILE" 2>&1 &
else
    echo "CRITICAL ERROR: Wallust NOT found at $WALLUST_BIN" >> "$LOG_FILE"
fi

if [[ "$img_path" == *.gif ]]; then
    temp_frame="/tmp/matugen_frame.png"
    magick "$img_path[0]" "$temp_frame"
    # --- MATUGEN COMMENTED OUT ---
    # matugen image "$temp_frame"
    magick "$temp_frame" -gravity Center -extent 1:1 "$HOME/.config/hypr/current_wallpaper_square" &
    (sleep 5 && rm "$temp_frame") &
else
    # --- MATUGEN COMMENTED OUT ---
    # matugen image "$img_path"
    magick "$img_path" -gravity Center -extent 1:1 "$HOME/.config/hypr/current_wallpaper_square" &
fi

# 4. WAIT & FADE IN
sleep 2
animate_opacity "in"

# 5. FINAL SYNC
echo "Waiting for Wallust process..." >> "$LOG_FILE"
while pgrep -x "wallust" > /dev/null; do sleep 0.1; done
echo "Wallust finished." >> "$LOG_FILE"

hyprctl reload
hyprctl keyword decoration:active_opacity "$target_opacity"
hyprctl keyword decoration:inactive_opacity "$target_opacity"

# --- UI RELOADS ---
gdbus emit --session /org/gtk/gtk4/ThemeChange org.gtk.gtk4.ThemeChange.ThemeChanged 2>/dev/null &

exit 0
