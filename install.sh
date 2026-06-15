#!/bin/bash

# --- Setup for GitHub shared config ---
# Folders to ship: dunst, gtk-3.0, gtk-4.0, hypr, kitty, qt6ct, rofi, wal, waybar

set -e

echo "Starting Arch Linux Hyprland setup installation..."

# 1. Update system
sudo pacman -Syu --noconfirm

# 2. Install essential base-devel and git
sudo pacman -S --needed --noconfirm base-devel git

# 3. Install paru (AUR helper)
if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
fi

# 4. Install dependencies
echo "Installing dependencies..."
PKGS=(
    # Hyprland and tools
    "hyprland" "hyprpaper" "hypridle" "hyprlock" "hyprsunset" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk"
    
    # UI Elements
    "waybar" "dunst" "rofi-wayland" "kitty" "firefox"
    
    # Appearance & Theming
    "python-pywal" "qt6ct" "nwg-look" "bibata-cursor-theme" "ttf-hack-nerd" "ttf-jetbrains-mono"
    
    # System Utilities
    "polkit-kde-agent" "libpulse" "brightnessctl" "fastfetch" "shuf" "libnotify" "bluetuith"
    
    # Keyd
    "keyd"
)

paru -S --needed --noconfirm "${PKGS[@]}"

# 5. Configure keyd
echo "Configuring keyd..."
sudo mkdir -p /etc/keyd
sudo bash -c 'cat <<EOF > /etc/keyd/default.conf
[ids]
*

[main]
leftshift = overload(shift, esc)
102nd = leftshift
EOF'

sudo systemctl enable --now keyd

# 6. Copy configuration files
echo "Copying configuration files..."
mkdir -p ~/.config
CONFIG_DIRS=("dunst" "gtk-3.0" "gtk-4.0" "hypr" "kitty" "qt6ct" "rofi" "wal" "waybar")

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "./$dir" ]; then
        cp -r "./$dir" ~/.config/
    else
        echo "Warning: Directory ./$dir not found in current folder."
    fi
done

# Create Wallpapers directory
echo "Creating Wallpapers directory..."
mkdir -p ~/Wallpapers

# 7. Make scripts executable
echo "Making scripts executable..."
if [ -d "$HOME/.config/hypr/scripts" ]; then
    find "$HOME/.config/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} +
fi

# 8. Shell setup (Optional)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "Installation complete!"
echo "Note: You might need to run pywal once to generate colors: wal -i /path/to/wallpaper"
