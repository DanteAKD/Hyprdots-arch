#!/bin/bash
# Hyprland Install Script

set -euo pipefail

# Ask for sudo password upfront
if [[ "$EUID" -ne 0 ]]; then
  echo "🔐 Sudo is required. Please enter your password."
  sudo -v
fi

# Keep sudo alive while the script runs
( while true; do sudo -v; sleep 60; done ) &
KEEP_SUDO_ALIVE_PID=$!
trap 'kill $KEEP_SUDO_ALIVE_PID' EXIT

# Clone the Hyprdots repository if not already present
REPO_URL="https://github.com/DanteAKD/Hyprdots-arch.git"
REPO_DIR="Hyprdots-arch"

if [[ -d "$REPO_DIR" ]]; then
  echo "📁 Directory $REPO_DIR already exists. Removing it first..."
  rm -rf "$REPO_DIR"
fi

echo "⬇️ Cloning Hyprdots repository..."
git clone --depth 1 "$REPO_URL"
cd "$REPO_DIR"

# System update
echo "🔄 Updating system packages..."
pacman -Syu --noconfirm

# Prompt for the target username
read -rp "👤 Enter the username for config installation: " USERNAME

USER_HOME="/home/$USERNAME"

if ! id "$USERNAME" &>/dev/null; then
  echo "❌ User '$USERNAME' does not exist. Exiting."
  exit 1
fi

# Define config directories to remove
CONFIG_PATH="$USER_HOME/.config"
CONFIGS_TO_REMOVE=(
  fish ranger alacritty cava dunst fastfetch hypr
  nvim rofi waybar
)

echo "🧹 Removing existing config directories..."
for dir in "${CONFIGS_TO_REMOVE[@]}"; do
  TARGET="$CONFIG_PATH/$dir"
  if [[ -e "$TARGET" ]]; then
    echo "  🗑️ Removing $TARGET"
    rm -rf "$TARGET"
  fi
done

# Copy new configs
echo "📁 Copying new configs to $CONFIG_PATH..."
mkdir -p "$CONFIG_PATH"
cp -r home/.config/* "$CONFIG_PATH"

# Fix ownership
echo "🛠️ Fixing ownership for $USERNAME..."
chown -R "$USERNAME:$USERNAME" "$CONFIG_PATH"

# Install Hyprland and required packages
echo "📦 Installing Hyprland and related tools..."
pacman -S --noconfirm --needed \
  swww swaylock grim slurp swappy wl-clipboard cliphist \
  waybar hyprland rofi-wayland dunst imagemagick \
  xdg-desktop-portal-hyprland jq

echo "✅ Hyprland environment installed successfully!"
