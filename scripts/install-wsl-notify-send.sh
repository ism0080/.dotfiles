#!/usr/bin/env bash

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

print_success() {
    echo -e "${GREEN}✓${RESET} $1"
}

print_error() {
    echo -e "${RED}✗${RESET} $1" >&2
}

print_info() {
    echo -e "${CYAN}ℹ${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} $1"
}

# Check if running in WSL
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    print_error "This script must be run from WSL"
    exit 1
fi

print_info "Installing wsl-notify-send..."

# Create installation directory
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Download URL
DOWNLOAD_URL="https://github.com/stuartleeks/wsl-notify-send/releases/download/v0.1.871612270/wsl-notify-send_windows_amd64.zip"
TEMP_DIR=$(mktemp -d)
ZIP_FILE="$TEMP_DIR/wsl-notify-send.zip"
EXTRACT_DIR="$TEMP_DIR/extracted"

# Download the zip file
print_info "Downloading from GitHub..."
if curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL"; then
    print_success "Downloaded successfully"
else
    print_error "Failed to download wsl-notify-send"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Extract the zip file
print_info "Extracting archive..."
mkdir -p "$EXTRACT_DIR"
if unzip -q "$ZIP_FILE" -d "$EXTRACT_DIR"; then
    print_success "Extracted successfully"
else
    print_error "Failed to extract archive"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Find and copy the executable
print_info "Installing to $INSTALL_DIR..."
if [ -f "$EXTRACT_DIR/wsl-notify-send.exe" ]; then
    cp "$EXTRACT_DIR/wsl-notify-send.exe" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/wsl-notify-send.exe"
    print_success "Installed wsl-notify-send.exe to $INSTALL_DIR"
else
    print_error "Could not find wsl-notify-send.exe in the archive"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"

# Verify installation
if command -v wsl-notify-send.exe >/dev/null 2>&1; then
    print_success "wsl-notify-send.exe is now available in PATH"
else
    print_warning "wsl-notify-send.exe installed but not in PATH"
    print_info "Make sure $INSTALL_DIR is in your PATH"
    print_info "Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

print_success "Installation complete!"
print_info "You can now use wsl-notify-send.exe to send Windows notifications from WSL"
