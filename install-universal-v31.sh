#!/bin/sh
# install-universal-v31.sh
# Installer for Amnezia-UI v3.1.0 (Merlin + gnuton), AmneziaWG 1.5 CPS/I1-I5
set -eu

SCRIPT_URL_BASE="https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main"
INSTALL_LOG="/tmp/amnezia-ui-install.log"
APP_NAME="amnezia-ui"
SCRIPT_TARGET="/jffs/scripts/${APP_NAME}"
ADDONS_DIR="/jffs/addons/${APP_NAME}"

log(){ echo "[$(date +'%F %T')] $*" | tee -a "$INSTALL_LOG"; }
need(){ command -v "$1" >/dev/null 2>&1 || { log "Missing $1"; return 1; }; }

log "Starting ${APP_NAME} v3.1.0 installation..."

# Ensure directories
mkdir -p "$ADDONS_DIR" "$ADDONS_DIR/bin" "$ADDONS_DIR/www" "$ADDONS_DIR/conf"

# Fetch main launcher
log "Downloading launcher..."
curl -fsSL "$SCRIPT_URL_BASE/amnezia-ui-universal-v31.sh" -o "$SCRIPT_TARGET"
chmod 0755 "$SCRIPT_TARGET"

# Optionally fetch backend/web assets if present
if curl -fsI "$SCRIPT_URL_BASE/bin/ui-backend" >/dev/null 2>&1; then
  curl -fsSL "$SCRIPT_URL_BASE/bin/ui-backend" -o "$ADDONS_DIR/bin/ui-backend" && chmod 0755 "$ADDONS_DIR/bin/ui-backend"
fi
if curl -fsI "$SCRIPT_URL_BASE/www/index.html" >/dev/null 2>&1; then
  curl -fsSL "$SCRIPT_URL_BASE/www/index.html" -o "$ADDONS_DIR/www/index.html"
fi

# Dependencies (best-effort)
if command -v opkg >/dev/null 2>&1; then
  log "Installing dependencies via Entware..."
  opkg update || true
  opkg install jq ipset git-http ca-bundle || true
fi

# Install hook and start web backend
"$SCRIPT_TARGET" install || true
"$SCRIPT_TARGET" web start || true

log "Installation finished. Use: /jffs/scripts/${APP_NAME} --help"
