#!/bin/bash
# install.sh - Fedora Asahi Master Setup (v2.1)
# Updates: No emojis, updated deps for nchat/kew, added uv/viu.

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[INFO] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

# 0. Safety Check
if [ ! -f "pkglist.txt" ]; then
    error "pkglist.txt not found! You must run this from the dotfiles folder."
    exit 1
fi

log "Starting Installation..."

# 1. DNF Init & Repos
log "Enabling Repositories (Hyprland, Yazi, RPMFusion)..."
sudo dnf update -y
sudo dnf install -y 'dnf5-command(copr)' 

sudo dnf copr enable solopasha/hyprland -y
sudo dnf copr enable atim/yazi -y

# Enable RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. Install Build Dependencies (Consolidated)
log "Installing Build Tools, Compilers, and Libraries..."

# Base Tools
BASE_TOOLS="git stow unzip curl pkgconf-pkg-config make automake gcc gcc-c++"

# Nchat Dependencies (Golang, Cmake, etc.)
NCHAT_DEPS="cmake clang golang ccache file-devel file-libs gperf readline-devel openssl-devel ncurses-devel sqlite-devel zlib-devel"

# Kew Dependencies (Audio libs, Chafa, Taglib)
# Note: Removed duplicates (git, gcc, make, gcc-c++) already in BASE_TOOLS
KEW_DEPS="taglib-devel fftw-devel opus-devel opusfile-devel libvorbis-devel libogg-devel chafa-devel libatomic glib2-devel"

# Install everything in one go
sudo dnf install -y $BASE_TOOLS $NCHAT_DEPS $KEW_DEPS

# 3. Codec Swap (Fixes Video)
log "Swapping ffmpeg-free for full ffmpeg..."
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
sudo dnf install -y libavcodec-freeworld gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly

# 4. Install Packages from List
log "Installing Packages from pkglist.txt..."
grep -vE "^\s*#|^\s*$" pkglist.txt | xargs sudo dnf install -y --skip-unavailable --allowerasing

# 5. Manual Builds
log "Starting Manual Builds..."
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

# --- A. Build nchat ---
if ! command -v nchat &> /dev/null; then
    log "   -> Building nchat..."
    git clone https://github.com/d99kris/nchat.git
    cd nchat && ./make.sh && sudo make install && cd ..
else
    log "   -> nchat already installed."
fi

# --- B. Build kew ---
if ! command -v kew &> /dev/null; then
    log "   -> Building kew (from Codeberg)..."
    git clone https://codeberg.org/ravachol/kew.git
    cd kew
    make -j4
    sudo make install
    cd ..
else
    log "   -> kew already installed."
fi

# --- C. Install uv & viu ---
if ! command -v uv &> /dev/null; then
    log "   -> Installing uv (required for viu)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to path temporarily for this script
    export PATH="$HOME/.cargo/bin:$PATH"
fi

if ! command -v viu &> /dev/null; then
    log "   -> Installing viu via uv..."
    uv tool install "viu-media[standard]" --force
else
    log "   -> viu already installed."
fi

# --- D. Nerd Fonts ---
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR" ]; then
    log "Installing Meslo Nerd Font..."
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    curl -fLo "Meslo.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
    unzip -q -o Meslo.zip
    rm Meslo.zip
    fc-cache -fv
fi

cd ~/dotfiles
rm -rf "$BUILD_DIR"

# 6. Dotfiles Linking
log "Linking Dotfiles..."

# Clean conflicts
rm -f ~/.zshrc ~/.bashrc ~/.bash_profile ~/.gitconfig ~/.config/mimeapps.list
rm -rf ~/.config/hypr ~/.config/kitty ~/.config/waybar ~/.config/wofi

# Ignore list
cat << EOF > .stow-local-ignore
install.sh
pkglist.txt
.git
.gitignore
README.md
EOF

# Stow
stow -R */

# 7. Secrets Setup (Interactive)
log "Setting up Secrets..."
echo -e "${GREEN}?? Do you want to clone your secrets (API keys) now?${NC}"
echo "   (y) Yes - I have my GitHub Token ready to type."
echo "   (n) No  - I will do this later in the GUI (Easier Copy-Paste)."
read -p "Select option [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ ! -d "$HOME/secure_keys" ]; then
        log "   -> Cloning secure_keys..."
        git clone https://github.com/Kushagra1203/secure_keys.git ~/secure_keys
        cd ~/secure_keys
        stow -R .
    else
        cd ~/secure_keys
        stow -R .
    fi

    # 8. Restore SSH Keys (Only if secrets were cloned)
    log "Restoring SSH Keys..."
    mkdir -p ~/.ssh
    if [ -d "$HOME/secure_keys/ssh_backup" ]; then
        cp -r ~/secure_keys/ssh_backup/* ~/.ssh/
        chmod 700 ~/.ssh
        chmod 600 ~/.ssh/id_ed25519 2>/dev/null
        chmod 644 ~/.ssh/id_ed25519.pub 2>/dev/null
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519 2>/dev/null
        log "SSH Keys restored."
    else
        error "No SSH backup found in secure_keys."
    fi
else
    log "Skipping Secrets. Remember to clone 'secure_keys' manually after reboot!"
fi

# 9. Final Polish
log "Finishing up..."
sudo systemctl enable sddm 2>/dev/null
sudo systemctl set-default graphical.target 2>/dev/null

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    log "Changing shell to Zsh..."
    sudo usermod --shell $(which zsh) $USER
fi

echo "==========================================="
echo "INSTALLATION COMPLETE! Please Reboot."
echo "==========================================="
