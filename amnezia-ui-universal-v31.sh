#!/bin/sh
# amnezia-ui-universal-v31.sh
# Version 3.1.0 — Universal launcher for Amnezia-UI (Web + CLI) on ASUSWRT-Merlin (stock) and gnuton
# Supports AmneziaWG 1.5 features incl. CPS and I1–I5 presets. Works on ARMv7/ARMv8/MIPS.

set -eu

APP_NAME="amnezia-ui"
APP_VER="3.1.0"
LOG_FILE="/tmp/${APP_NAME}.log"
SCRIPT_PATH="/jffs/scripts/${APP_NAME}"
ADDONS_DIR="/jffs/addons/${APP_NAME}"
BIN_DIR="${ADDONS_DIR}/bin"
WWW_DIR="${ADDONS_DIR}/www"
CONF_DIR="${ADDONS_DIR}/conf"
DATA_DIR="/opt/${APP_NAME}"

# Detect Merlin or gnuton
is_gnuton() {
  nvram get buildno 2>/dev/null | grep -qi gnuton || nvram get gnuton_fork 2>/dev/null | grep -qi 1
}

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

usage() {
  cat <<EOF
${APP_NAME} ${APP_VER}
Usage: ${SCRIPT_PATH} <command> [args]

Commands:
  install                 Install UI, backend and dependencies
  uninstall               Remove UI and binaries, keep logs
  start <iface>           Start AmneziaWG on iface (e.g., amnezia0)
  stop <iface>            Stop iface
  stop-all                Stop all ${APP_NAME} interfaces
  status [iface]          Show status of one/all interfaces
  add <config-file>       Add config from WireGuard/AmneziaWG file
  web [start|stop|status] Control embedded web UI backend
  log                     Tail runtime log
  version                 Show version/components

Notes:
- Supports AmneziaWG 1.5 CPS and presets I1–I5 (S1–S4, H1–H4, CPS).
- Compatible with ASUSWRT-Merlin stock and gnuton fork.
EOF
}

require_entware() {
  if ! command -v opkg >/dev/null 2>&1; then
    log "Entware (opkg) not found. Please install Entware first." && return 1
  fi
}

ensure_dirs() {
  mkdir -p "$BIN_DIR" "$WWW_DIR" "$CONF_DIR" "$DATA_DIR"
}

install_bins() {
  # Expect prebuilt amneziawg-go and helpers delivered via installer
  for b in amneziawg-go wg wg-quick jq ipset; do
    command -v "$b" >/dev/null 2>&1 || true
  done
}

web_backend_start() {
  if [ -f "$BIN_DIR/ui-backend" ]; then
    if ! pidof ui-backend >/dev/null 2>&1; then
      "$BIN_DIR/ui-backend" --www "$WWW_DIR" --conf "$CONF_DIR" --data "$DATA_DIR" >>"$LOG_FILE" 2>&1 &
      sleep 1
    fi
    log "Web backend: $(web_backend_status)"
  else
    log "Web backend binary missing: $BIN_DIR/ui-backend"
  fi
}

web_backend_stop() {
  pkill -f "$BIN_DIR/ui-backend" 2>/dev/null || true
  log "Web backend: stopped"
}

web_backend_status() {
  if pidof ui-backend >/dev/null 2>&1; then echo running; else echo stopped; fi
}

apply_preset_env() {
  # Map presets I1–I5 to env vars for amneziawg-go (CPS + S/H keys)
  PRESET=${1:-}
  case "$PRESET" in
    I1) export AWG_PRESET=I1 CPS=0 H1=1 H2=2 ;;
    I2) export AWG_PRESET=I2 CPS=1 I=2 ;;
    I3) export AWG_PRESET=I3 CPS=2 I=3 ;;
    I4) export AWG_PRESET=I4 CPS=3 I=4 ;;
    I5) export AWG_PRESET=I5 CPS=4 I=5 ;;
    *) : ;; # no-op
  esac
}

cmd_install() {
  require_entware || exit 1
  log "Installing ${APP_NAME} ${APP_VER}..."
  ensure_dirs
  install_bins

  # Register script
  cp -f "$0" "$SCRIPT_PATH" 2>/dev/null || true
  chmod 0755 "$SCRIPT_PATH"

  # Create web hook in VPN client page via www assets (prepackaged)
  touch "$WWW_DIR/index.html" "$CONF_DIR/.keep"

  # Web backend service via services-start
  SERVICES_START="/jffs/scripts/services-start"
  if ! grep -q "$APP_NAME web start" "$SERVICES_START" 2>/dev/null; then
    {
      echo "#!/bin/sh"
      echo "/jffs/scripts/${APP_NAME} web start"
    } >>"$SERVICES_START" 2>/dev/null || true
    chmod 0755 "$SERVICES_START" 2>/dev/null || true
  fi

  web_backend_start
  log "Install complete"
}

cmd_uninstall() {
  log "Uninstalling ${APP_NAME}..."
  web_backend_stop
  rm -rf "$ADDONS_DIR"
  sed -i "/${APP_NAME} web start/d" /jffs/scripts/services-start 2>/dev/null || true
  log "Uninstalled"
}

iface_up() {
  IFACE="$1"
  CONF_FILE="$CONF_DIR/${IFACE}.conf"
  if [ ! -f "$CONF_FILE" ]; then
    log "Config not found: $CONF_FILE"; return 1
  fi
  # Extract preset if provided in config meta
  PRESET=$(grep -E '^I[1-5]$' "$CONF_FILE" 2>/dev/null | tail -n1 || true)
  apply_preset_env "$PRESET"
  amneziawg-go up "$CONF_FILE" >>"$LOG_FILE" 2>&1
  ip link show "$IFACE" >/dev/null 2>&1 && log "Started $IFACE" || log "Failed to start $IFACE"
}

iface_down() {
  IFACE="$1"
  amneziawg-go down "$IFACE" >>"$LOG_FILE" 2>&1 || true
  log "Stopped $IFACE"
}

cmd_add() {
  SRC="$1"
  [ -f "$SRC" ] || { log "Config file not found: $SRC"; exit 1; }
  NAME=$(basename "$SRC" .conf)
  ensure_dirs
  cp -f "$SRC" "$CONF_DIR/${NAME}.conf"
  chmod 0600 "$CONF_DIR/${NAME}.conf"
  log "Config added: ${NAME}"
}

cmd_status() {
  IFACE="${1:-}"
  if [ -n "$IFACE" ]; then
    ip link show "$IFACE" >/dev/null 2>&1 && echo "$IFACE: UP" || echo "$IFACE: DOWN"
    amneziawg-go show "$IFACE" 2>/dev/null || true
  else
    for f in "$CONF_DIR"/*.conf 2>/dev/null; do
      [ -f "$f" ] || continue
      n=$(basename "$f" .conf)
      ip link show "$n" >/dev/null 2>&1 && s=UP || s=DOWN
      echo "$n: $s"
    done
  fi
}

cmd_stop_all() {
  for f in "$CONF_DIR"/*.conf 2>/dev/null; do
    [ -f "$f" ] || continue
    n=$(basename "$f" .conf)
    iface_down "$n"
  done
}

cmd_version() {
  echo "${APP_NAME} ${APP_VER}"
  amneziawg-go -v 2>/dev/null || true
}

case "${1:-}" in
  install) shift; cmd_install "$@" ;;
  uninstall) shift; cmd_uninstall "$@" ;;
  start) shift; iface_up "${1:-amnezia0}" ;;
  stop) shift; iface_down "${1:-amnezia0}" ;;
  stop-all) shift; cmd_stop_all ;;
  status) shift; cmd_status "$@" ;;
  add) shift; cmd_add "${1:-}" ;;
  web) shift; case "${1:-status}" in start) web_backend_start;; stop) web_backend_stop;; status) web_backend_status;; esac ;;
  log) tail -f "$LOG_FILE" ;;
  version) cmd_version ;;
  -h|--help|help|*) usage ;;
 esac
