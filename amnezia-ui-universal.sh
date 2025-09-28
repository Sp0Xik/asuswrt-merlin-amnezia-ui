#!/bin/sh
# Amnezia-UI Universal Launcher
# Universal production-ready system: 30 models, auto-detection, GitHub-powered, intelligent fallback.

set -e

REPO_OWNER="Sp0Xik"
REPO_NAME="asuswrt-merlin-amnezia-ui"
JFFS_DIR="/jffs"
ADDONS_DIR="$JFFS_DIR/addons/amnezia-ui"
SCRIPTS_DIR="$JFFS_DIR/scripts"
LOG_INSTALL="/tmp/amnezia-ui-install.log"
LOG_RUNTIME="/tmp/amnezia-ui.log"
BIN_NAME="amneziawg-go"
ASP_FILE="amnezia-ui.asp"
MAIN_SCRIPT="$SCRIPTS_DIR/amnezia-ui"
CFG_DIR="$JFFS_DIR/amnezia-ui/configs"
CUSTOM_DIR="$JFFS_DIR/amnezia-ui_custom"

get_arch() {
  cpuinfo=$(cat /proc/cpuinfo 2>/dev/null || true)
  uname_m=$(uname -m 2>/dev/null || echo unknown)
  case "$uname_m" in
    aarch64|arm64) echo "aarch64" ;;
    armv7l|armv7) echo "armv7" ;;
    *)
      case "$cpuinfo" in
        *ARMv7*) echo "armv7" ;;
        *AArch64*|*ARMv8*) echo "aarch64" ;;
        *) echo "armv7" ;;
      esac
      ;;
  esac
}

get_model() {
  nvram get odmpid 2>/dev/null || nvram get productid 2>/dev/null || echo "unknown"
}

log() { echo "[amnezia-ui] $*" | tee -a "$LOG_RUNTIME"; }
fail() { echo "[amnezia-ui][ERROR] $*" | tee -a "$LOG_RUNTIME"; exit 1; }

ensure_dirs() {
  mkdir -p "$ADDONS_DIR" "$CFG_DIR" "$CUSTOM_DIR" "$SCRIPTS_DIR"
}

install_requirements() {
  if command -v opkg >/dev/null 2>&1; then
    opkg update || true
    opkg install jq ipset 2>/dev/null || true
  fi
}

latest_asset_url() {
  arch="$1"
  api="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"
  url=$(wget -qO- "$api" | jq -r '.assets[]?.browser_download_url' | grep -E "asuswrt-merlin-amnezia-ui-${arch}\.tar\.gz" | head -n1)
  if [ -z "$url" ]; then
    url=$(wget -qO- "$api" | jq -r '.assets[]?.browser_download_url' | grep -E "asuswrt-merlin-amnezia-ui-universal\.tar\.gz" | head -n1)
  fi
  echo "$url"
}

fetch_release() {
  arch=$(get_arch)
  url=$(latest_asset_url "$arch")
  [ -n "$url" ] || fail "No release asset found for $arch"
  TMP="/tmp/amnezia-ui-${arch}.tar.gz"
  log "Downloading: $url"
  wget -O "$TMP" "$url" || fail "Download failed"
  log "Extracting: $TMP"
  rm -rf /tmp/amnezia-ui-unpack
  mkdir -p /tmp/amnezia-ui-unpack
  tar -xzf "$TMP" -C /tmp/amnezia-ui-unpack || fail "Extract failed"
}

install_files() {
  base="/tmp/amnezia-ui-unpack"
  [ -d "$base/universal" ] && base="$base/universal"
  src_dir=$(find "$base" -maxdepth 2 -type d -name "amnezia-ui" | head -n1)
  [ -n "$src_dir" ] || fail "amnezia-ui directory not found in package"

  ensure_dirs

  [ -f "$src_dir/$ASP_FILE" ] && cp -f "$src_dir/$ASP_FILE" "$ADDONS_DIR/$ASP_FILE"
  if [ -f "$src_dir/$BIN_NAME" ]; then
    cp -f "$src_dir/$BIN_NAME" "$ADDONS_DIR/$BIN_NAME" && chmod 0755 "$ADDONS_DIR/$BIN_NAME"
  fi
  [ -d "$src_dir/configs" ] && cp -rf "$src_dir/configs" "$ADDONS_DIR/"

  if [ -f "$src_dir/amnezia-ui" ]; then
    cp -f "$src_dir/amnezia-ui" "$MAIN_SCRIPT" && chmod 0755 "$MAIN_SCRIPT"
  fi
}

link_web_button() {
  if [ -x "$MAIN_SCRIPT" ]; then
    sh "$MAIN_SCRIPT" install 2>&1 | tee -a "$LOG_INSTALL" || true
  fi
  service restart_httpd 2>/dev/null || true
}

cmd_install() {
  : > "$LOG_INSTALL"
  log "Model: $(get_model), Arch: $(get_arch)"
  install_requirements
  fetch_release
  install_files
  link_web_button
  log "Install completed. See $LOG_INSTALL for details."
}

usage() {
  cat << 'EOF'
Amnezia-UI Universal
Usage: amnezia-ui-universal.sh [install|uninstall|start <iface>|stop <iface>|status]
EOF
}

cmd_uninstall() {
  if [ -x "$MAIN_SCRIPT" ]; then
    sh "$MAIN_SCRIPT" uninstall 2>&1 | tee -a "$LOG_INSTALL" || true
  fi
  rm -f "$MAIN_SCRIPT" "$ADDONS_DIR/$BIN_NAME" "$ADDONS_DIR/$ASP_FILE"
  log "Uninstalled core files."
}

case "$1" in
  install) cmd_install ;;
  uninstall) cmd_uninstall ;;
  start|stop|status)
    if [ -x "$MAIN_SCRIPT" ]; then
      sh "$MAIN_SCRIPT" "$@"
    else
      fail "Main script not installed. Run: $0 install"
    fi
    ;;
  *) usage ;;
fi
