#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

mkdir -p "$BACKUP_DIR"

echo "Select dotfiles or directories to import (use TAB to multi-select, ENTER to confirm):"

# Use fzf to select files/folders interactively
selected_items=$(ls -A "$DOTFILES_DIR" | fzf --multi)

# Check if user selected anything
if [ -z "$selected_items" ]; then
  echo "No selection made, exiting."
  exit 1
fi

for item in $selected_items; do
    SRC="$DOTFILES_DIR/$item"
    DEST="$HOME/$item"

    if [ ! -e "$SRC" ]; then
        echo "⚠️  $item does not exist in $DOTFILES_DIR, skipping."
        continue
    fi

    if [ -e "$DEST" ]; then
        echo "Backing up existing $DEST to $BACKUP_DIR/"
        mv "$DEST" "$BACKUP_DIR/"
    fi

    echo "Copying $SRC to $DEST"
    rsync -a --delete "$SRC" "$DEST"
done

echo "Done importing dotfiles!"

