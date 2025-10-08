#!/bin/bash
set -euo pipefail

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
# Safety checks
# ──────────────────────────────────────────────

# 1. Make sure we're online
if ! ping -c1 github.com &>/dev/null; then
    echo "❌ Internet seems to be down. Connect and try again."
    exit 1
fi

# 2. Detect if script was run from curl or locally
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    echo "⚙️  Running as local script."
else
    echo "🌐  Running via curl (remote install)."
fi

# 3. Sanity: check that we’re not missing half the file (simple heuristic)
if ! grep -q "✅ Setup complete!" "$0"; then
    echo "⚠️  This script looks incomplete or corrupted. Aborting for safety."
    exit 1
fi

sleep 1
echo
echo "Let's get you set up..."
sleep 1
echo




# ──────────────────────────────────────────────
# Basic setup
# ──────────────────────────────────────────────
REPO_URL="https://github.com/elcapitino/.dotfiles.git"
SETUP_DIR="$HOME/.local/share/dotsetup"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

# ──────────────────────────────────────────────
# Clone repo if missing or update it
# ──────────────────────────────────────────────
if [ ! -d "$SETUP_DIR" ]; then
    echo "[+] Cloning setup repo into $SETUP_DIR..."
    git clone "$REPO_URL" "$SETUP_DIR"
else
    echo "[=] Setup repo already exists. Updating..."
    git -C "$SETUP_DIR" pull
fi

# ──────────────────────────────────────────────
# Helper: install package if missing (Arch)
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
# Essential packages for CachyOS + Hyprland
# ──────────────────────────────────────────────
echo "[+] Checking and installing missing packages..."

install_pkg stow
install_pkg walker
install_pkg rofi
install_pkg dunst
install_pkg swww
install_pkg wl-clipboard
install_pkg grim
install_pkg slurp

# ──────────────────────────────────────────────
# Ensure yay (AUR helper) exists
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
# LazyVim setup
# ──────────────────────────────────────────────
if [ ! -d "$HOME/.config/nvim" ]; then
    echo "[+] Installing LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    echo "[=] LazyVim installed. Run Neovim once to finish setup."
else
    echo "[=] Neovim config already exists, skipping LazyVim setup."
fi

# ──────────────────────────────────────────────
# Symlink configs (with stow)
# ──────────────────────────────────────────────
echo "[+] Linking configs with stow..."
cd "$SETUP_DIR/configs"
stow -t "$CONFIG_DIR" *

# ──────────────────────────────────────────────
# Copy scripts in bin/
# ──────────────────────────────────────────────
mkdir -p "$BIN_DIR"
cp -r "$SETUP_DIR/bin/"* "$BIN_DIR/" || true
chmod +x "$BIN_DIR/"* || true

# ──────────────────────────────────────────────
# Final message
# ──────────────────────────────────────────────
echo
echo "✅ Setup complete!"
echo "Configs linked to $CONFIG_DIR"
echo "Scripts copied to $BIN_DIR"
echo "Repository cloned at $SETUP_DIR"
echo
echo "👉 Tip: Reboot or reload Hyprland for new configs to take effect."

