#!/bin/bash

# ============================================
# Gitleaks Hook Installer
# Auto-installs gitleaks and pre-commit hook
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

GITLEAKS_VERSION="8.18.4"
HOOK_REPO="https://raw.githubusercontent.com/Iamfittz/gitleaks-hook/main"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Gitleaks Pre-Commit Hook Installer  ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect OS and architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Linux*)     OS_TYPE="linux" ;;
        Darwin*)    OS_TYPE="darwin" ;;
        MINGW*|MSYS*|CYGWIN*) OS_TYPE="windows" ;;
        *)          echo -e "${RED}[ERROR]${NC} Unsupported OS: $OS"; exit 1 ;;
    esac

    case "$ARCH" in
        x86_64|amd64)  ARCH_TYPE="x64" ;;
        arm64|aarch64) ARCH_TYPE="arm64" ;;
        i386|i686)     ARCH_TYPE="x32" ;;
        *)             echo -e "${RED}[ERROR]${NC} Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    echo -e "${GREEN}[OK]${NC} Detected: $OS_TYPE ($ARCH_TYPE)"
}

# Install gitleaks
install_gitleaks() {
    if command -v gitleaks &> /dev/null; then
        CURRENT_VERSION=$(gitleaks version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}[OK]${NC} Gitleaks already installed: $CURRENT_VERSION"
        return 0
    fi

    echo -e "${YELLOW}[INFO]${NC} Installing gitleaks v${GITLEAKS_VERSION}..."

    # Build download URL
    case "$OS_TYPE" in
        linux)
            FILENAME="gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_TYPE}.tar.gz"
            ;;
        darwin)
            FILENAME="gitleaks_${GITLEAKS_VERSION}_darwin_${ARCH_TYPE}.tar.gz"
            ;;
        windows)
            FILENAME="gitleaks_${GITLEAKS_VERSION}_windows_${ARCH_TYPE}.zip"
            ;;
    esac

    DOWNLOAD_URL="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/${FILENAME}"
    
    echo -e "${YELLOW}[INFO]${NC} Downloading from: $DOWNLOAD_URL"

    # Create temp directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    # Download
    if command -v curl &> /dev/null; then
        curl -sSL -o "$FILENAME" "$DOWNLOAD_URL"
    elif command -v wget &> /dev/null; then
        wget -q -O "$FILENAME" "$DOWNLOAD_URL"
    else
        echo -e "${RED}[ERROR]${NC} Neither curl nor wget found"
        exit 1
    fi

    # Extract
    if [[ "$FILENAME" == *.tar.gz ]]; then
        tar -xzf "$FILENAME"
    else
        unzip -q "$FILENAME"
    fi

    # Install binary
    if [ "$OS_TYPE" = "windows" ]; then
        INSTALL_PATH="/usr/local/bin"
        mkdir -p "$INSTALL_PATH"
        mv gitleaks.exe "$INSTALL_PATH/" 2>/dev/null || mv gitleaks "$INSTALL_PATH/"
    else
        sudo mv gitleaks /usr/local/bin/ 2>/dev/null || mv gitleaks /usr/local/bin/
    fi

    # Cleanup
    cd - > /dev/null
    rm -rf "$TMP_DIR"

    echo -e "${GREEN}[OK]${NC} Gitleaks installed successfully"
}

# Install pre-commit hook
install_hook() {
    # Check if we're in a git repo
    if [ ! -d ".git" ]; then
        echo -e "${RED}[ERROR]${NC} Not a git repository. Run this from your project root."
        exit 1
    fi

    echo -e "${YELLOW}[INFO]${NC} Installing pre-commit hook..."

    # Download hook
    curl -sSL -o .git/hooks/pre-commit "${HOOK_REPO}/hooks/pre-commit"
    
    # Make executable
    chmod +x .git/hooks/pre-commit

    echo -e "${GREEN}[OK]${NC} Pre-commit hook installed"
}

# Enable hook via git config
enable_hook() {
    git config hooks.gitleaks true