#!/bin/sh
# Multi-architecture installer for Amnezia-UI
# Auto-detects router architecture and downloads appropriate package
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

# Detect architecture
echo "Detecting router architecture..."
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

# Map architecture to package suffix
case "$ARCH" in
    "armv7l"|"arm")
        PKG_ARCH="armv7"
        echo "Using ARMv7 package"
        ;;
    "aarch64"|"arm64")
        PKG_ARCH="aarch64" 
        echo "Using AArch64/ARM64 package"
        ;;
    "mips"|"mipsel")
        PKG_ARCH="mips"
        echo "Using MIPS package"
        ;;
    *)
        echo "Warning: Unknown architecture '$ARCH', trying AArch64 as fallback..."
        PKG_ARCH="aarch64"
        ;;
esac

# Download architecture-specific package
echo "Downloading $PKG_ARCH package..."
cd /tmp
PKG_NAME="amnezia-ui-package-$PKG_ARCH.tar.gz"
wget -q "https://github.com/$REPO/releases/latest/download/$PKG_NAME" || {
    echo "Error: Failed to download $PKG_NAME"
    echo "Available packages: armv7, aarch64, mips"
    echo "Please download manually from: https://github.com/$REPO/releases/latest"
    exit 1
}

# Verify download
if [ ! -f "$PKG_NAME" ]; then
    echo "Error: Package file not found after download"
    exit 1
fi
echo "Downloaded $(ls -lh $PKG_NAME | awk '{print $5}') package"

# Extract
echo "Extracting..."
mkdir -p "$ADDON_DIR"
tar -xzf "$PKG_NAME" -C /tmp || {
    echo "Error: Extract failed"
    exit 1
}

# Verify extracted structure
if [ ! -d "/tmp/addons/amneziaui" ]; then
    echo "Error: Invalid package structure - missing addons/amneziaui directory"
    exit 1
fi

# Move files to correct locations with better error handling
echo "Installing files..."
# Use cp with recursive flag and then remove source, which is more reliable than mv with glob
cp -r /tmp/addons/amneziaui/* "$ADDON_DIR/" 2>/dev/null || {
    echo "Error: Failed to copy addon files"
    echo "Debug information:"
    echo "Source directory contents:"
    ls -la /tmp/addons/amneziaui/ 2>/dev/null || echo "Source directory not accessible"
    echo "Target directory: $ADDON_DIR"
    echo "Target directory exists: $([ -d "$ADDON_DIR" ] && echo 'Yes' || echo 'No')"
    exit 1
}

# Copy main script to scripts directory
cp "$ADDON_DIR/amnezia-ui" "$SCRIPT_DIR/" 2>/dev/null || {
    echo "Error: Failed to copy main script"
    exit 1
}

# Set permissions
echo "Setting permissions..."
chmod 0755 "$SCRIPT_DIR/amnezia-ui"
chmod 0755 "$ADDON_DIR/"*

# Create custom hooks directory
mkdir -p "$CUSTOM_DIR"

# Merlin firmware detection and .asusrouter marker creation (YazFi/Diversion/XRAYUI pattern)
echo "Checking firmware compatibility..."
FIRMWARE_INFO=$(uname -a 2>/dev/null || echo "unknown")
if echo "$FIRMWARE_INFO" | grep -qi "merlin"; then
    echo "✓ Merlin firmware detected: Creating compatibility marker"
    if [ ! -f "/jffs/.asusrouter" ]; then
        echo "Creating /jffs/.asusrouter marker file for addon compatibility..."
        touch "/jffs/.asusrouter" 2>/dev/null || {
            echo "Warning: Could not create /jffs/.asusrouter marker file"
            echo "You may need to create it manually: touch /jffs/.asusrouter"
        }
        if [ -f "/jffs/.asusrouter" ]; then
            echo "✓ Compatibility marker created successfully"
        fi
    else
        echo "✓ Compatibility marker already exists"
    fi
else
    echo "ⓘ Non-Merlin firmware detected - skipping .asusrouter marker creation"
    echo "  If you encounter addon compatibility issues, manually create: touch /jffs/.asusrouter"
fi

# Verify installation
echo "Verifying installation..."
if [ -f "$SCRIPT_DIR/amnezia-ui" ] && [ -f "$ADDON_DIR/amnezia-ui" ] && [ -f "$ADDON_DIR/amneziawg-go" ]; then
    echo "✓ Main script installed"
    echo "✓ Addon files installed"
    echo "✓ Architecture-specific binary installed ($PKG_ARCH)"
else
    echo "✗ Installation verification failed"
    echo "Check if all files are present:"
    ls -la "$SCRIPT_DIR/amnezia-ui" "$ADDON_DIR/" 2>/dev/null || true
    exit 1
fi

# Show version info if available
if [ -f "$ADDON_DIR/version.info" ]; then
    echo "\nInstalled version info:"
    cat "$ADDON_DIR/version.info"
fi

# Cleanup
rm -f "/tmp/$PKG_NAME"
rm -rf /tmp/addons

echo "\n🎉 Installation complete!"
echo "\nNext steps:"
echo "1. Run: amnezia-ui install"
echo "2. Add configuration: amnezia-ui add /path/to/config.conf"
echo "3. Start interface: amnezia-ui start amnezia0"
echo "4. Start web UI: amnezia-ui web start"
echo "\nFor help: amnezia-ui --help"
