#!/bin/bash

# Path to the wallpaper directory
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Get the list of connected monitors, excluding the first line
monitors=$(xrandr --listactivemonitors | tail -n +2 | grep -Eo ' [^ ]+$')

# Convert monitors to array
monitors_array=($monitors)

# Get the number of monitors
num_monitors=${#monitors_array[@]}

# Get a list of all wallpapers in the specified directory and subdirectories
wallpaper_files=($(find "$WALLPAPER_DIR" -type f -name "*.png" -o -name "*.jpg" -o -name "*.jpeg"))

# Shuffle the list of wallpapers
shuffled_wallpapers=($(shuf -e "${wallpaper_files[@]}"))

# If there are fewer wallpapers than monitors, repeat the wallpapers
while [ ${#shuffled_wallpapers[@]} -lt $num_monitors ]; do
  shuffled_wallpapers+=("${shuffled_wallpapers[@]}")
done

# Pick a number of wallpapers equal to the number of monitors
selected_wallpapers=(${shuffled_wallpapers[@]:0:$num_monitors})

# Loop through the monitors and set a wallpaper for each
for i in "${!monitors_array[@]}"; do
  xwallpaper --output "${monitors_array[i]}" --stretch "${selected_wallpapers[i]}"
done
