#!/bin/bash

# Get wallpaper path from Waypaper
img="$1"

# Log it
echo "$(date): Setting $img" >> "$HOME/wallpaper-change.log"

# Apply wallpaper via swww
swww img "$img" --transition-type fade --transition-duration 2

# ============================================================
# 1. QUICKSHELL UPDATE (DISABLED)
# ============================================================
# This runs in the background so it doesn't slow down the rest
# QS_CONFIG="$HOME/.config/quickshell/ii/config.json"
# QS_COLORS="$HOME/.local/state/quickshell/user/generated/colors.json"
# QS_SCRIPT="$HOME/.config/quickshell/ii/scripts/colors/generate_colors_material.py"

# Update the wallpaper path in Quickshell's config
# if [ -f "$QS_CONFIG" ]; then
#    jq --arg wp "$img" '.background.wallpaperPath = $wp' "$QS_CONFIG" > "/tmp/qs_config.tmp" && mv "/tmp/qs_config.tmp" "$QS_CONFIG"
# fi

# Force regenerate Quickshell colors
# (This uses the python script we fixed to output pure JSON)
# if [ -f "$QS_SCRIPT" ]; then
#    mkdir -p "$(dirname "$QS_COLORS")"
#    python "$QS_SCRIPT" --path "$img" > "$QS_COLORS" &
# fi

# ============================================================
# ROFI WALLPAPER LINK
# ============================================================
# Create a symlink to the current wallpaper so Rofi can find it
ln -sf "$img" "$HOME/.config/hypr/current_wallpaper"

# Uses ImageMagick to create the perfect 1:1 center cut
# NOTE: Ensure you have ImageMagick installed (sudo dnf install ImageMagick)
magick "$img" -gravity Center -extent 1:1 "$HOME/.config/hypr/current_wallpaper_square"

# ============================================================
# 2. UPDATE HYPRPANEL + MATUGEN
# ============================================================

# Run Matugen (Hyprpanel will overwrite later)
matugen image "$img"

# Update Hyprpanel wallpaper reference (for theme generation)
# NOTE: Ensure you have jq installed (sudo dnf install jq)
jq --arg wp "$img" \
   '.["wallpaper.image"] = $wp | .["wallpaper.enable"] = false' \
   ~/.config/hyprpanel/config.json > /tmp/hp.json
mv /tmp/hp.json ~/.config/hyprpanel/config.json

# Restart Hyprpanel so it regenerates theme/colors first
pkill -f hyprpanel
sleep 0.3
hyprpanel &>/dev/null &


# ============================================================
# 3. NOW RELOAD HYPRLAND + TERMINALS
# ============================================================

# Hot reload Hyprland
hyprctl reload

# Hot reload Kitty colors
kitty @ set-colors --all ~/.config/kitty/kitty-theme.conf
pkill -SIGUSR1 kitty


# ============================================================
# 4. PORTALS + GTK REFRESH
# ============================================================

systemctl --user restart xdg-desktop-portal.service
systemctl --user restart xdg-desktop-portal-gtk.service
systemctl --user restart xdg-desktop-portal-wlr.service

touch ~/.config/gtk-3.0/gtk.css
touch ~/.config/gtk-4.0/gtk.css 2>/dev/null

# GTK4 refresh
gdbus emit --session \
  /org/gtk/gtk4/ThemeChange \
  org.gtk.gtk4.ThemeChange.ThemeChanged 2>/dev/null

# GTK3 refresh
gdbus emit --session \
  /org/gnome/SettingsDaemon/Plugins/Theme \
  org.gnome.SettingsDaemon.Plugins.Theme.ThemeChanged 2>/dev/null

# -----------------------------------------------------
# Wait for matugen to finish
while pgrep -f "matugen" >/dev/null; do
    sleep 0.05
done
exit 0
