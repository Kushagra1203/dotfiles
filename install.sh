#!/bin/bash
# install.sh - The Master Setup Script for Fedora Minimal

set -e # Exit immediately if a command fails

echo "==========================================="
echo "   Kushagra's Fedora Master Setup Script   "
echo "==========================================="

# 1. Update System
echo "🔄 Updating system repositories..."
sudo dnf update -y

# 2. Install Git & Stow (Required for the rest)
echo "📦 Installing Git and Stow..."
sudo dnf install -y git stow

# 3. Install Packages from List
if [ -f "pkglist.txt" ]; then
    echo "📦 Installing packages from pkglist.txt..."
    # We use xargs to install efficiently
    sudo dnf install -y $(cat pkglist.txt)
else
    echo "⚠️  WARNING: pkglist.txt not found! Skipping package installation."
fi

# 4. Setup Public Dotfiles
echo "🔗 Stowing Public Dotfiles..."
# We assume this script is running from inside ~/dotfiles
stow . 

# 5. Setup Private Secrets
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

# 6. Shell Setup
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "🐚 Changing default shell to Zsh..."
    chsh -s $(which zsh)
fi

echo "==========================================="
echo "✅ SETUP COMPLETE! REBOOT YOUR COMPUTER."
echo "==========================================="
