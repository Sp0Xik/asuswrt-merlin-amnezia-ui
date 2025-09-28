#!/bin/sh
# Multi-architecture installer for Amnezia-UI
# Adds persistent ASP overlay/patch hooks to ASUSWRT-Merlin router UI
REPO="Sp0Xik/asuswrt-merlin-amnezia-ui"
ADDON_DIR="/jffs/addons/amneziaui"
SCRIPT_DIR="/jffs/scripts"
CUSTOM_DIR="/jffs/amneziaui_custom"
OVERLAY_DIR="/jffs/overlay/www"
STOCK_WWW="/www"
VPN_ASP="Advanced_VPN_Content.asp"
VPN_TABS_ASP="VPN.asp"
FIREWALL_ASP="Advanced_Firewall_Content.asp"
echo "Installing Amnezia-UI..."
# Check JFFS
if [ ! -d "/jffs" ]; then
    echo "Error: JFFS not enabled"; exit 1
fi
# Detect architecture
echo "Detecting router architecture..."
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
case "$ARCH" in
    armv7l|arm) PKG_ARCH="armv7"; echo "Using ARMv7 package" ;;
    aarch64|arm64) PKG_ARCH="aarch64"; echo "Using AArch64/ARM64 package" ;;
    mips|mipsel) PKG_ARCH="mips"; echo "Using MIPS package" ;;
    *) echo "Warning: Unknown architecture '$ARCH', trying AArch64 as fallback..."; PKG_ARCH="aarch64" ;;
esac
# Download package
cd /tmp || exit 1
PKG_NAME="amnezia-ui-package-$PKG_ARCH.tar.gz"
echo "Downloading $PKG_NAME ..."
wget -q "https://github.com/$REPO/releases/latest/download/$PKG_NAME" || { echo "Download failed"; exit 1; }
[ -f "$PKG_NAME" ] || { echo "Package missing after download"; exit 1; }
echo "Downloaded $(ls -lh $PKG_NAME | awk '{print $5}')"
# Extract
mkdir -p "$ADDON_DIR"
tar -xzf "$PKG_NAME" -C /tmp || { echo "Extract failed"; exit 1; }
[ -d "/tmp/addons/amneziaui" ] || { echo "Invalid package structure"; exit 1; }
# Install files
echo "Installing files..."
cp -r /tmp/addons/amneziaui/* "$ADDON_DIR/" || { echo "Copy failed"; exit 1; }
# Copy wrapper to scripts
cp "$ADDON_DIR/amnezia-ui" "$SCRIPT_DIR/" 2>/dev/null || true
chmod 0755 "$SCRIPT_DIR/amnezia-ui" 2>/dev/null || true
chmod 0755 "$ADDON_DIR/"* 2>/dev/null || true
mkdir -p "$CUSTOM_DIR"
# Merlin detection and marker
FIRMWARE_INFO=$(uname -a 2>/dev/null || echo "unknown")
if echo "$FIRMWARE_INFO" | grep -qi merlin; then
  [ -f /jffs/.asusrouter ] || touch /jffs/.asusrouter 2>/dev/null || true
fi
# Verify
if [ -f "$ADDON_DIR/amneziawg-go" ]; then echo "✓ Binary present ($PKG_ARCH)"; else echo "✗ Binary missing"; fi
# Initialize addon (creates ASP page, hooks)
"$ADDON_DIR/amnezia-ui" install || "$SCRIPT_DIR/amnezia-ui" install || true
# Auto-start hooks (services-start + init-start) for overlay/patch
mkdir -p "$SCRIPT_DIR"
# services-start
if ! grep -q "amneziaui/amnezia-ui" "$SCRIPT_DIR/services-start" 2>/dev/null; then
  cat >> "$SCRIPT_DIR/services-start" <<'EOSVC'
#!/bin/sh
# Amnezia-UI autostart + sed patch fallback
/jffs/addons/amneziaui/amnezia-ui web start >/dev/null 2>&1 &
sleep 5
/jffs/addons/amneziaui/amnezia-ui web asp-status >/dev/null 2>&1 || true
/jffs/addons/amneziaui/amnezia-ui ui patch >/dev/null 2>&1 || true
EOSVC
  chmod 755 "$SCRIPT_DIR/services-start"
fi
# init-start
if ! grep -q "amneziaui/amnezia-ui ui overlay" "$SCRIPT_DIR/init-start" 2>/dev/null; then
  cat >> "$SCRIPT_DIR/init-start" <<'EOINIT'
#!/bin/sh
/jffs/addons/amneziaui/amnezia-ui web start >/dev/null 2>&1 &
sleep 5
/jffs/addons/amneziaui/amnezia-ui ui overlay >/dev/null 2>&1 || true
EOINIT
  chmod 755 "$SCRIPT_DIR/init-start"
fi
# Start web now
"$ADDON_DIR/amnezia-ui" web start || "$SCRIPT_DIR/amnezia-ui" web start || true
# Cleanup
rm -f "/tmp/$PKG_NAME"; rm -rf /tmp/addons
printf "\n🎉 Installation complete!\n"
echo "Web interface: http://$(nvram get lan_ipaddr 2>/dev/null || echo 192.168.1.1):8080"
echo "Mini-UI: http://router-ip/user_amneziaui.asp (now also in VPN tab list)"
