#!/bin/bash

THEMES_DIR="$HOME/.dotfiles/themes"
SWITCH_SCRIPT="$HOME/.dotfiles/bin/switch-theme"  # whatever your switch script is

# Get theme list
theme_list=$(ls "$THEMES_DIR" | sort)

# Use walker to choose
selected=$(echo "$theme_list" | walker -l)

if [ -n "$selected" ]; then
    "$SWITCH_SCRIPT" "$selected"
    notify-send "Theme changed to $selected"
else
    echo "No theme selected."
fi

