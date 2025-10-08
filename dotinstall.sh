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
REPO_URL="https://github.com/elcapitino.dotfiles.git"
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
# Helper: check + install package (for Arch)
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
# Install essentials
# ──────────────────────────────────────────────
install_pkg git
install_pkg base-devel
install_pkg fzf
install_pkg rofi
install_pkg stow
install_pkg waybar
install_pkg starship

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
# Install AUR packages
# ──────────────────────────────────────────────
if command -v yay &>/dev/null; then
    echo "[+] Installing AUR packages (walker, lazyvim)..."
    yay -S --needed --noconfirm walker lazyvim
fi

# ──────────────────────────────────────────────
# Detect correct source layout
# ──────────────────────────────────────────────
if [ -d "$SETUP_DIR/.dotfiles" ]; then
    DOTFILES_DIR="$SETUP_DIR/.dotfiles"
else
    DOTFILES_DIR="$SETUP_DIR"
fi

# ──────────────────────────────────────────────
# Symlink configs (using stow)
# ──────────────────────────────────────────────
if [ -d "$DOTFILES_DIR/config" ]; then
    echo "[+] Linking config files..."
    mkdir -p "$CONFIG_DIR"
    cd "$DOTFILES_DIR/config"
    stow -t "$CONFIG_DIR" .
else
    echo "[!] No config directory found. Skipping..."
fi

# ──────────────────────────────────────────────
# Copy bin scripts
# ──────────────────────────────────────────────
if [ -d "$DOTFILES_DIR/bin" ]; then
    echo "[+] Copying scripts to $BIN_DIR..."
    mkdir -p "$BIN_DIR"
    cp -r "$DOTFILES_DIR/bin/"* "$BIN_DIR/" || true
    chmod +x "$BIN_DIR/"* || true
else
    echo "[!] No bin directory found. Skipping..."
fi

# ──────────────────────────────────────────────
# Optional extras (themes, apps, etc.)
# ──────────────────────────────────────────────
for dir in themes applications defaults migration; do
    SRC="$DOTFILES_DIR/$dir"
    if [ -d "$SRC" ]; then
        echo "[=] Found $dir directory — skipping or handle manually later."
    fi
done

# ──────────────────────────────────────────────
# Final message
# ──────────────────────────────────────────────
echo
echo "✅ Setup complete!"
echo "Configs linked to $CONFIG_DIR"
echo "Scripts available in $BIN_DIR"
echo "Repository cloned at $SETUP_DIR"
echo
echo "You can now reload Hyprland or run your menu shortcut!"

