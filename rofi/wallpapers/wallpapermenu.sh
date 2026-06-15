#!/bin/bash

THEME="$HOME/.config/rofi/wallpapers/wallpapermenu.rasi"
WALLPAPER_DIR="$HOME/Wallpapers"
THUMB_DIR="$HOME/.cache/rofi_wall_thumbnails"

# Create thumbnail directory if it doesn't exist
mkdir -p "$THUMB_DIR"

if [ ! -d "$WALLPAPER_DIR" ]; then
  rofi -e "Wallpaper directory not found: $WALLPAPER_DIR" -theme "$THEME"
  exit 1
fi

# Function to generate Rofi list with thumbnails
generate_rofi_list() {
  find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) | while read -r wallpaper_path;
  do
    thumbnail_name=$(basename "$wallpaper_path")
    thumbnail_path="$THUMB_DIR/$thumbnail_name"

    if [ ! -f "$thumbnail_path" ]; then
      convert "$wallpaper_path" -thumbnail 256x256^ -gravity center -extent 256x256 "$thumbnail_path"
    fi
    
    printf "%s\0icon\x1f%s\n" "$(basename "$wallpaper_path")" "$thumbnail_path"
  done
}

# Get selected filename from Rofi
SELECTED_FILENAME=$(generate_rofi_list | rofi -dmenu -i -p "Select Wallpaper:" -theme "$THEME")

# If a wallpaper was selected, call the random_wallpaper script with the full path
if [ -n "$SELECTED_FILENAME" ]; then
  # Construct the full path
  SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_FILENAME"
  # Call the other script to set the wallpaper and update themes
  "$HOME/.config/hypr/scripts/themin/random-wallpaper.sh" "$SELECTED_PATH"
fi
