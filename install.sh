#!/bin/bash
# install.sh - The Master Setup Script for Fedora Minimal

set -e # Exit immediately if a command fails

echo "==========================================="
echo "   Kushagra's Fedora Master Setup Script   "
echo "==========================================="

# 1. Update System
echo "🔄 Updating system repositories..."
sudo dnf update -y

# 2. Install Git, Stow, and Build Tools
echo "📦 Installing Git, Stow, and Compilers..."
sudo dnf install -y git stow
# specific group install for compiling (needed for nchat/kew)
sudo dnf groupinstall -y "Development Tools" 

# 3. Install Packages from List
if [ -f "pkglist.txt" ]; then
    echo "📦 Installing packages from pkglist.txt..."
    # We use xargs to install efficiently
    sudo dnf install -y $(cat pkglist.txt)
else
    echo "⚠️  WARNING: pkglist.txt not found! Skipping package installation."
fi

# ---------------------------------------------------------
# 4. MANUAL BUILDS & FONTS (The "Hidden 20%")
# ---------------------------------------------------------

echo "🛠️  Starting Manual Builds..."

# Create a temp directory for building to keep home clean
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

# --- A. Build nchat ---
if ! command -v nchat &> /dev/null; then
    echo "   -> Building nchat (C++)..."
    # Install dependencies specific to nchat
    sudo dnf install -y ncurses-devel sqlite-devel libcurl-devel file-devel openssl-devel
    
    git clone https://github.com/d99kris/nchat.git
    cd nchat
    ./make.sh
    sudo make install
    cd ..
else
    echo "   -> nchat is already installed."
fi

# --- B. Build kew ---
if ! command -v kew &> /dev/null; then
    echo "   -> Building kew (Music Player)..."
    # Install dependencies specific to kew
    sudo dnf install -y fftw-devel opusfile-devel chafa-devel taglib-devel libcurl-devel
    
    git clone https://github.com/ravachol/kew.git
    cd kew
    make
    sudo make install
    cd ..
else
    echo "   -> kew is already installed."
fi

# --- C. Install Meslo Nerd Font ---
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR" ]; then
    echo "🔤 Installing Meslo Nerd Font..."
    mkdir -p "$FONT_DIR"
    # Download directly to font dir
    cd "$FONT_DIR"
    curl -fLo "Meslo.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
    unzip -o Meslo.zip
    rm Meslo.zip
    # Refresh font cache
    fc-cache -fv
    echo "   -> Fonts installed."
else
    echo "   -> Fonts directory exists. Skipping."
fi

# Clean up build directory
rm -rf "$BUILD_DIR"
echo "✅ Manual builds complete."

# ---------------------------------------------------------
# 5. DOTFILES & SECRETS
# ---------------------------------------------------------

# Return to dotfiles folder (we moved to temp earlier)
cd ~/dotfiles

# Setup Public Dotfiles
echo "🔗 Stowing Public Dotfiles..."
stow . 

# Setup Private Secrets
echo "==========================================="
echo "🔐 SECRETS SETUP"
echo "We need to clone your private 'secure_keys' repo."
echo "You will be asked for your GitHub Username and PAT (Token)."
echo "==========================================="

if [ ! -d "$HOME/secure_keys" ]; then
    git clone https://github.com/Kushagra1203/secure_keys.git ~/secure_keys
    
    echo "🔗 Stowing Secrets..."
    cd ~/secure_keys
    stow .
else
    echo "✅ secure_keys folder already exists. Skipping clone."
    cd ~/secure_keys
    stow -R .
fi

# ---------------------------------------------------------
# 6. SHELL & FINISH
# ---------------------------------------------------------

# Shell Setup
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🐚 Changing default shell to Zsh..."
    chsh -s $(which zsh)
fi

echo "==========================================="
echo "✅ SETUP COMPLETE! REBOOT YOUR COMPUTER."
echo "==========================================="
