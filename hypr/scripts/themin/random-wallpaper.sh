#!/usr/bin/env bash
WALLPAPERS_DIR="$HOME/Wallpapers"

if [ -n "${1:-}" ]; then
    WALLPAPER="$1"
else
    WALLPAPER=$(find "$WALLPAPERS_DIR" -type f \( \
      -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
    \) | shuf -n 1)
fi

[ -n "$WALLPAPER" ] || exit 1

ln -sf "$WALLPAPER" "$HOME/Wallpapers/current_wallpaper"

wal -i "$WALLPAPER"
"$HOME/.config/hypr/scripts/themin/generate_hypr_colors.sh"

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "eDP-1, $WALLPAPER, cover"
cp /home/valenyqs/.cache/wal/colors-kitty.conf /home/valenyqs/.config/kitty/colors-kitty.conf
hyprctl reload
killall waybar; waybar &
killall rofi
kitty @ set-colors -a -c "$HOME/.cache/wal/colors-kitty.conf"
sudo chmod 644 "$WALLPAPER"
