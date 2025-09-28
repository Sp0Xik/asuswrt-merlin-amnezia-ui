#!/bin/sh
# XRAYUI-style installer for Amnezia-UI
# Simple wget+tar+mv+chmod pattern

REPO="Sp0Xik/asuswrt-merlin-amnezia-ui"
ADDON_DIR="/jffs/addons/amneziaui"
SCRIPT_DIR="/jffs/scripts"
CUSTOM_DIR="/jffs/amneziaui_custom"

echo "Installing Amnezia-UI..."

# Check JFFS
if [ ! -d "/jffs" ]; then
    echo "Error: JFFS not enabled"
    exit 1
fi

# Download package
echo "Downloading release package..."
cd /tmp
wget -q https://github.com/$REPO/releases/latest/download/amnezia-ui-package.tar.gz || {
    echo "Error: Download failed"
    exit 1
}

# Extract
echo "Extracting..."
mkdir -p "$ADDON_DIR"
tar -xzf amnezia-ui-package.tar.gz -C /tmp || {
    echo "Error: Extract failed"
    exit 1
}

# Move files to correct locations
echo "Installing files..."
mv /tmp/addons/amneziaui/* "$ADDON_DIR/" 2>/dev/null
cp "$ADDON_DIR/amnezia-ui" "$SCRIPT_DIR/" 2>/dev/null || {
    echo "Error: Failed to copy main script"
    exit 1
}

# Set permissions
chmod 0755 "$SCRIPT_DIR/amnezia-ui"
chmod 0755 "$ADDON_DIR/"*

# Create custom hooks directory
mkdir -p "$CUSTOM_DIR"

# Cleanup
rm -f /tmp/amnezia-ui-package.tar.gz
rm -rf /tmp/addons

echo "Installation complete!"
echo "Run: amnezia-ui install"
