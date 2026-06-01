#!/bin/bash

# --- CONFIG & LOGGING ---
LIST_DIR="$HOME/.local/share/chezmoi/.install-lists"
LOG="$HOME/bootstrap_error.log"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "--- Bootstrap Log $(date) ---" > "$LOG"
log() { echo -e "${GREEN}[INFO] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }

# --- 0. PRE-FLIGHT CLEANUP ---
# Clean version numbers and human-fluff from your uploaded lists
[ -f "$LIST_DIR/pip_packages.txt" ] && cut -d'=' -f1 "$LIST_DIR/pip_packages.txt" > "$LIST_DIR/clean_pip.txt"
[ -f "$LIST_DIR/pipx_tools.txt" ] && grep "package" "$LIST_DIR/pipx_tools.txt" | awk '{print $2}' > "$LIST_DIR/clean_pipx.txt"

# Helper function for loop-based installs with error logging
safe_install() {
    local manager=$1; local list_file=$2; local cmd=$3
    [ ! -f "$list_file" ] && return
    log "Installing $manager packages..."
    while IFS= read -r item || [ -n "$item" ]; do
        [[ -z "$item" || "$item" =~ ^# ]] && continue
        # Skip items hardcoded in the "Specials" section to avoid version conflicts
        [[ "$item" == "viu" || "$item" == "bagels" || "$item" == "jams" || "$item" == "mpd-mpris" ]] && continue
        
        echo "  -> $item"
        $cmd "$item" >> "$LOG" 2>&1 || echo "[FAILED] $manager: $item" | tee -a "$LOG"
    done < "$list_file"
}

# --- 1. REPOSITORY & SYSTEM INIT ---
log "Enabling Asahi/Fedora Repositories..."
sudo dnf update -y
sudo dnf install -y 'dnf5-command(copr)' 
sudo dnf copr enable solopasha/hyprland -y
sudo dnf copr enable atim/yazi -y
sudo dnf copr enable kazeev/kew -y # Added for official kew support

# Enable RPMFusion for codecs
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# --- 2. DNF (SYSTEM, BUILD HEADERS & CODECS) ---
log "Installing System Base, Codecs, and Build Dependencies..."
# Consolidated build deps for Cargo, Pip, nchat, and kew
sudo dnf install -y --skip-broken \
    python3-devel gcc-c++ openssl-devel dbus-devel alsa-lib-devel \
    gtk4-devel glib2-devel sqlite-devel cmake clang golang ccache \
    file-devel gperf readline-devel ncurses-devel zlib-devel \
    taglib-devel fftw-devel opus-devel opusfile-devel libvorbis-devel \
    chafa-devel libatomic libavcodec-freeworld \
    $(cat "$LIST_DIR/dnf_packages.txt")

# Swap to full ffmpeg for proper video support
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y

# --- 3. HARDCODED SPECIALS (AUDITED FLAGS) ---
log "Installing tools with specific requirements..."

# UV/Viu
uv tool install --python 3.13 bagels >> "$LOG" 2>&1
uv tool install "viu-media[standard]" >> "$LOG" 2>&1

# [cite_start]GO [cite: 1]
go install github.com/natsukagami/mpd-mpris@latest >> "$LOG" 2>&1

# [cite_start]PIPX [cite: 5, 28]
pipx install --python python3.13 jams >> "$LOG" 2>&1

# [cite_start]CARGO Specials [cite: 2]
cargo install --git https://github.com/S-Sigdel/hyprDrover.git >> "$LOG" 2>&1

# --- 4. THE LOOPS (FOR GENERIC LISTS) ---
safe_install "Cargo" "$LIST_DIR/cargo_packages.txt" "cargo install"
safe_install "Pip" "$LIST_DIR/clean_pip.txt" "pip install --user"
safe_install "Pipx" "$LIST_DIR/clean_pipx.txt" "pipx install"
safe_install "NPM" "$LIST_DIR/npm_global.txt" "sudo npm install -g"
safe_install "Flatpak" "$LIST_DIR/flatpak_apps.txt" "flatpak install -y flathub"

# --- 5. MANUAL BUILDS (FOR NON-REPO TOOLS) ---
log "Starting Manual Builds..."
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

# nchat Build logic
if ! command -v nchat &> /dev/null; then
    log "Building nchat..."
    git clone https://github.com/d99kris/nchat.git
    cd nchat && ./make.sh && sudo make install && cd ..
fi

# --- 6. FINAL POLISH ---
log "Configuring System State..."
sudo systemctl enable sddm 2>/dev/null
sudo systemctl set-default graphical.target 2>/dev/null

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    sudo usermod --shell $(which zsh) $USER
fi

log "--- INSTALLATION COMPLETE! Please Reboot. ---"
log "Check $LOG for any failures."
