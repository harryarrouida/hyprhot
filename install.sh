#!/bin/bash

# --- Setup for GitHub shared config ---
# Folders to ship: dunst, gtk-3.0, gtk-4.0, hypr, kitty, qt6ct, rofi, wal, waybar

set -e

# 0. Prevent running as root directly
if [ "$EUID" -eq 0 ]; then
    echo "Error: Please do NOT run this script as root/sudo."
    echo "It will automatically request sudo permissions when needed."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting Arch Linux Hyprland setup installation..."

# 1. Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install essential base-devel and git
echo "Installing base-devel and git..."
sudo pacman -S --needed --noconfirm base-devel git

# Helper function to check if an AUR helper is installed and working
is_working_helper() {
    local helper="$1"
    command -v "$helper" &>/dev/null && "$helper" --version &>/dev/null
}

# 3. Install or fix AUR helper
if is_working_helper "paru"; then
    AUR_HELPER="paru"
elif is_working_helper "yay"; then
    AUR_HELPER="yay"
else
    echo "No working AUR helper found (existing helper might be broken due to a pacman update)."
    echo "Installing yay from source (fast and links to the current libalpm)..."
    
    # Remove any conflicting/old directories
    rm -rf "$SCRIPT_DIR/yay"
    
    git clone https://aur.archlinux.org/yay.git "$SCRIPT_DIR/yay"
    cd "$SCRIPT_DIR/yay"
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf "$SCRIPT_DIR/yay"
    AUR_HELPER="yay"
fi
echo "Using AUR helper: $AUR_HELPER"

# 4. Install dependencies
echo "Installing dependencies..."
PKGS=(
    # Hyprland and tools
    "hyprland" "hyprpaper" "hypridle" "hyprlock" "hyprsunset" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk"
    
    # UI Elements & Applications
    "waybar" "dunst" "rofi-wayland" "kitty" "firefox" "thunar" "pavucontrol"
    
    # Appearance & Theming
    "python-pywal" "qt6ct" "nwg-look" "bibata-cursor-theme" "ttf-hack-nerd" "ttf-jetbrains-mono" "imagemagick"
    
    # System Utilities
    "polkit-kde-agent" "libpulse" "brightnessctl" "fastfetch" "libnotify" "bluetuith" "playerctl" "hyprshot"
    
    # Shell & Keyd
    "zsh" "keyd"
)

# Filter package list to only install what is not already satisfied
TO_INSTALL=()
for pkg in "${PKGS[@]}"; do
    # pacman -T returns 0 if the dependency is already satisfied
    if pacman -T "$pkg" &>/dev/null; then
        echo "  [✓] $pkg is already satisfied"
    else
        echo "  [+] $pkg needs to be installed"
        TO_INSTALL+=("$pkg")
    fi
done

if [ ${#TO_INSTALL[@]} -eq 0 ]; then
    echo "All dependencies are already satisfied!"
else
    echo "Installing missing dependencies..."
    $AUR_HELPER -S --needed --noconfirm "${TO_INSTALL[@]}"
fi

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
mkdir -p "$HOME/.config"
CONFIG_DIRS=("dunst" "gtk-3.0" "gtk-4.0" "hypr" "kitty" "qt6ct" "rofi" "wal" "waybar")

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        cp -r "$SCRIPT_DIR/$dir" "$HOME/.config/"
    else
        echo "Warning: Directory $SCRIPT_DIR/$dir not found in repository."
    fi
done

# Create Wallpapers directory and supply default ones if empty
echo "Setting up Wallpapers directory..."
mkdir -p "$HOME/Wallpapers"

# 7. Make scripts executable
echo "Making scripts executable..."
find "$HOME/.config" -type f -name "*.sh" -exec chmod +x {} +

# 8. Shell setup (Optional)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Set up oh-my-zsh plugins
ZSH_CUSTOM_DIR="$HOME/.oh-my-zsh/custom"
if [ -d "$ZSH_CUSTOM_DIR" ]; then
    echo "Installing custom oh-my-zsh plugins..."
    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
        echo "Cloning zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
    fi
    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
        echo "Cloning zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    fi
    
    # Configure ~/.zshrc to enable plugins
    if [ -f "$HOME/.zshrc" ]; then
        echo "Configuring plugins in ~/.zshrc..."
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$HOME/.zshrc"
        else
            echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> "$HOME/.zshrc"
        fi
    fi
fi

if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    echo "Changing default shell to zsh..."
    sudo chsh -s /usr/bin/zsh "$USER"
fi

# 9. Initialize theme color caches to prevent Hyprland config loading crashes
echo "Initializing theme color caches..."
if command -v wal &> /dev/null; then
    WALLPAPER=$(find "$HOME/Wallpapers" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | shuf -n 1)
    if [ -n "$WALLPAPER" ]; then
        echo "Generating initial colors from wallpaper: $WALLPAPER"
        ln -sf "$WALLPAPER" "$HOME/Wallpapers/current_wallpaper"
        
        # Run pywal to generate colors-hyprland.lua from the template
        wal -i "$WALLPAPER" -q || true
        
        # Run generate_hypr_colors.sh to create the cache files
        GEN_COLORS_SCRIPT="$HOME/.config/hypr/scripts/themin/generate_hypr_colors.sh"
        if [ -f "$GEN_COLORS_SCRIPT" ]; then
            chmod +x "$GEN_COLORS_SCRIPT"
            bash "$GEN_COLORS_SCRIPT" || true
            echo "Theme cache initialized successfully."
        else
            echo "Warning: generate_hypr_colors.sh not found."
        fi
    else
        echo "Warning: No wallpaper found in ~/Wallpapers. Cannot initialize theme cache."
    fi
else
    echo "Warning: Pywal ('wal') not installed. Cannot initialize theme cache."
fi

echo "Installation complete!"
echo "Note: You might need to run pywal once to generate colors: wal -i /path/to/wallpaper"
echo "You can also choose wallpapers interactively with SUPER + W"
