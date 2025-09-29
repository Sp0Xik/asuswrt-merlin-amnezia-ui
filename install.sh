#!/bin/sh
# POSIX/BusyBox-safe installer for Amnezia-UI (ASUSWRT-Merlin)
# - No bashisms, minimal deps, works with /bin/sh BusyBox
# - Auto-detect arch, fetch latest package, install, set hooks

REPO="Sp0Xik/asuswrt-merlin-amnezia-ui"
ADDON_DIR="/jffs/addons/amneziaui"
SCRIPT_DIR="/jffs/scripts"
CUSTOM_DIR="/jffs/amneziaui_custom"
OVERLAY_DIR="/jffs/overlay/www"
STOCK_WWW="/www"

set -u

echo "Installing Amnezia-UI..."
# Check JFFS
if [ ! -d "/jffs" ]; then
    echo "Error: JFFS not enabled"; exit 1
fi

# Ensure PATH has Entware if present
if [ -d /opt/bin ]; then PATH="/opt/sbin:/opt/bin:$PATH"; export PATH; fi

# Detect arch (BusyBox compatible)
echo "Detecting router architecture..."
ARCH="$(uname -m 2>/dev/null || echo unknown)"
echo "Detected architecture: $ARCH"
case "$ARCH" in
  armv7l|arm)   PKG_ARCH="armv7" ; echo "Using ARMv7 package" ;;
  aarch64|arm64)PKG_ARCH="aarch64" ; echo "Using AArch64/ARM64 package" ;;
  mips|mipsel)  PKG_ARCH="mips" ; echo "Using MIPS package" ;;
  *)            PKG_ARCH="aarch64" ; echo "Warning: unknown arch, using AArch64 fallback" ;;
esac

# Download package
cd /tmp || exit 1
PKG_NAME="amnezia-ui-package-$PKG_ARCH.tar.gz"
echo "Downloading $PKG_NAME ..."
if command -v wget >/dev/null 2>&1; then
  wget -q "https://github.com/$REPO/releases/latest/download/$PKG_NAME" || { echo "Download failed"; exit 1; }
elif command -v curl >/dev/null 2>&1; then
  curl -fsSL -o "$PKG_NAME" "https://github.com/$REPO/releases/latest/download/$PKG_NAME" || { echo "Download failed"; exit 1; }
else
  echo "Neither wget nor curl available"; exit 1
fi
[ -f "$PKG_NAME" ] || { echo "Package missing after download"; exit 1; }
ls -lh "/tmp/$PKG_NAME" 2>/dev/null | awk '{print "Downloaded "$5}' || true

# Extract and install
mkdir -p "$ADDON_DIR" || { echo "mkdir failed"; exit 1; }
tar -xzf "$PKG_NAME" -C /tmp || { echo "Extract failed"; exit 1; }
[ -d "/tmp/addons/amneziaui" ] || { echo "Invalid package structure"; exit 1; }

echo "Installing files..."
cp -r /tmp/addons/amneziaui/* "$ADDON_DIR/" || { echo "Copy failed"; exit 1; }

# Wrapper to scripts
mkdir -p "$SCRIPT_DIR" "$CUSTOM_DIR" 2>/dev/null || true
cp "$ADDON_DIR/amnezia-ui" "$SCRIPT_DIR/" 2>/dev/null || true
chmod 0755 "$SCRIPT_DIR/amnezia-ui" 2>/dev/null || true
chmod 0755 "$ADDON_DIR/"* 2>/dev/null || true

# Merlin marker
if uname -a 2>/dev/null | grep -qi merlin; then
  [ -f /jffs/.asusrouter ] || touch /jffs/.asusrouter 2>/dev/null || true
fi

# Verify binary
if [ -f "$ADDON_DIR/amneziawg-go" ]; then echo "✓ Binary present ($PKG_ARCH)"; else echo "✗ Binary missing"; fi

# Initialize addon (creates ASP pages, hooks)
"$ADDON_DIR/amnezia-ui" install || "$SCRIPT_DIR/amnezia-ui" install || true

# Auto-start hooks
mkdir -p "$SCRIPT_DIR"
# services-start
if ! grep -q "amneziaui/amnezia-ui" "$SCRIPT_DIR/services-start" 2>/dev/null; then
  {
    echo "#!/bin/sh"
    echo "# Amnezia-UI autostart + ASP overlay patch"
    echo "/jffs/addons/amneziaui/amnezia-ui web start >/dev/null 2>&1 &"
    echo "sleep 5"
    echo "/jffs/addons/amneziaui/amnezia-ui web asp-status >/dev/null 2>&1 || true"
    echo "/jffs/addons/amneziaui/amnezia-ui ui patch >/dev/null 2>&1 || true"
  } >>"$SCRIPT_DIR/services-start"
  chmod 755 "$SCRIPT_DIR/services-start"
fi
# init-start
if ! grep -q "amneziaui/amnezia-ui ui overlay" "$SCRIPT_DIR/init-start" 2>/dev/null; then
  {
    echo "#!/bin/sh"
    echo "/jffs/addons/amneziaui/amnezia-ui web start >/dev/null 2>&1 &"
    echo "sleep 5"
    echo "/jffs/addons/amneziaui/amnezia-ui ui overlay >/dev/null 2>&1 || true"
  } >>"$SCRIPT_DIR/init-start"
  chmod 755 "$SCRIPT_DIR/init-start"
fi

# Ensure httpd provider if missing
if ! command -v httpd >/dev/null 2>&1; then
  if command -v busybox >/dev/null 2>&1; then :; else
    echo "No httpd found. Attempting Entware busybox (optional)..."
    if [ -x /opt/bin/opkg ]; then
      /opt/bin/opkg update >/dev/null 2>&1 || true
      /opt/bin/opkg install busybox >/dev/null 2>&1 || true
    else
      echo "Entware not detected at /opt. Web UI available only if httpd exists."
    fi
  fi
fi

# Start web now
"$ADDON_DIR/amnezia-ui" web start || "$SCRIPT_DIR/amnezia-ui" web start || true

# Cleanup
rm -f "/tmp/$PKG_NAME"; rm -rf /tmp/addons 2>/dev/null || true
printf "\nInstallation complete!\n"
IP="$(nvram get lan_ipaddr 2>/dev/null || echo 192.168.1.1)"
echo "Web interface: http://$IP:8080"
echo "Mini-UI (router ASP): http://router-ip/user_amneziaui.asp"
