#!/bin/bash
set -euo pipefail



# ──────────────────────────────────────────────
# Fancy intro
# ──────────────────────────────────────────────
clear
echo "──────────────────────────────────────────────"
echo " 🚀  Dotfiles Setup Script"
echo "──────────────────────────────────────────────"
echo "Running as: $(whoami) on $(hostname)"
echo "Current dir: $(pwd)"
echo "──────────────────────────────────────────────"
echo



# ──────────────────────────────────────────────
# Basic setup
# ──────────────────────────────────────────────
REPO_URL="https://github.com/elcapitino/.dotfiles.git"
SETUP_DIR="$HOME/.local/share/dotsetup"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

# ──────────────────────────────────────────────
# Clone repo if missing
# ──────────────────────────────────────────────
if [ ! -d "$SETUP_DIR" ]; then
    echo "[+] Cloning setup repo into $SETUP_DIR..."
    git clone "$REPO_URL" "$SETUP_DIR"
else
    echo "[=] Setup repo already exists. Updating..."
    git -C "$SETUP_DIR" pull
fi

# ──────────────────────────────────────────────
# Helper: check + install package (for pacman)
# ──────────────────────────────────────────────
install_pkg() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "[+] Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
    else
        echo "[=] $pkg already installed."
    fi
}

# ──────────────────────────────────────────────
# Base essentials (before yay)
# ──────────────────────────────────────────────
install_pkg git
install_pkg base-devel
install_pkg fzf
install_pkg rofi
install_pkg stow

# ──────────────────────────────────────────────
# Ensure yay is installed
# ──────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    echo "[+] Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
else
    echo "[=] yay already installed."
fi

# ──────────────────────────────────────────────
# Helper: install AUR packages
# ──────────────────────────────────────────────
aur_pkg() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "[+] Installing $pkg (AUR)..."
        yay -S --needed --noconfirm "$pkg"
    else
        echo "[=] $pkg already installed."
    fi
}

# ──────────────────────────────────────────────
# AUR installs
# ──────────────────────────────────────────────
aur_pkg walker
aur_pkg starship
aur_pkg lazyvim

# ──────────────────────────────────────────────
# Symlink configs (using stow)
# ──────────────────────────────────────────────
echo "[+] Linking config files..."
cd "$SETUP_DIR/configs"
stow -t "$CONFIG_DIR" *

# ──────────────────────────────────────────────
# Copy bin scripts
# ──────────────────────────────────────────────
mkdir -p "$BIN_DIR"
cp -r "$SETUP_DIR/bin/"* "$BIN_DIR/"
chmod +x "$BIN_DIR/"*

# ──────────────────────────────────────────────
# Final message
# ──────────────────────────────────────────────
echo
echo "✅ Setup complete!"
echo "Configs linked to $CONFIG_DIR"
echo "Scripts available in $BIN_DIR"
echo "Repository cloned at $SETUP_DIR"
