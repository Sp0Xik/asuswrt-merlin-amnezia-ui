#!/bin/sh

APP_NAME="Amnezia UI Universal"
APP_VER="v3.1.0"
CONF_DIR="/jffs/amnezia-ui/configs"
LOG_FILE="/jffs/amnezia-ui/amnezia.log"
WEB_DIR="/jffs/amnezia-ui/web"
WEB_PID_FILE="/var/run/amnezia-web.pid"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >>"$LOG_FILE"
}

usage() {
  cat <<EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
  install        Install Amnezia UI
  uninstall      Uninstall Amnezia UI
  start [NAME]   Start interface (default: amnezia0)
  stop [NAME]    Stop interface (default: amnezia0)
  stop-all       Stop all interfaces
  status [NAME]  Show interface status
  add FILE       Add config file
  web [start|stop|status]  Manage web backend
  log            Show logs
  version        Show version
  help           Show this help

EOF
}

ensure_dirs() {
  [ -d "$CONF_DIR" ] || mkdir -p "$CONF_DIR"
  [ -d "$WEB_DIR" ] || mkdir -p "$WEB_DIR"
  [ -d "$(dirname "$LOG_FILE")" ] || mkdir -p "$(dirname "$LOG_FILE")"
}

cmd_install() {
  log "Installing Amnezia UI..."
  ensure_dirs
  
  # Download amneziawg-go if not exists
  if [ ! -f "/jffs/amnezia-ui/amneziawg-go" ]; then
    log "Downloading amneziawg-go..."
    curl -L "https://github.com/amnezia-vpn/amneziawg-go/releases/latest/download/amneziawg-go-linux-mipsle" -o "/jffs/amnezia-ui/amneziawg-go" 2>>"$LOG_FILE"
    chmod +x "/jffs/amnezia-ui/amneziawg-go"
  fi
  
  # Create symlink
  ln -sf "/jffs/amnezia-ui/amneziawg-go" "/usr/bin/amneziawg-go" 2>>"$LOG_FILE"
  
  log "Installation completed"
}

cmd_uninstall() {
  log "Uninstalling Amnezia UI..."
  cmd_stop_all
  rm -rf "/jffs/amnezia-ui" 2>>"$LOG_FILE"
  rm -f "/usr/bin/amneziawg-go" 2>>"$LOG_FILE"
  log "Uninstallation completed"
}

web_backend_start() {
  if [ -f "$WEB_PID_FILE" ] && kill -0 "$(cat "$WEB_PID_FILE")" 2>/dev/null; then
    echo "Web backend already running"
    return
  fi
  
  log "Starting web backend..."
  nohup sh -c 'cd "$WEB_DIR" && python3 -m http.server 8080' >"$WEB_DIR/web.log" 2>&1 &
  echo $! >"$WEB_PID_FILE"
  echo "Web backend started on port 8080"
}

web_backend_stop() {
  if [ -f "$WEB_PID_FILE" ]; then
    PID=$(cat "$WEB_PID_FILE")
    if kill "$PID" 2>/dev/null; then
      log "Web backend stopped"
      rm -f "$WEB_PID_FILE"
    else
      log "Web backend was not running"
      rm -f "$WEB_PID_FILE"
    fi
  else
    echo "Web backend is not running"
  fi
}

web_backend_status() {
  if [ -f "$WEB_PID_FILE" ] && kill -0 "$(cat "$WEB_PID_FILE")" 2>/dev/null; then
    echo "Web backend is running (PID: $(cat "$WEB_PID_FILE"))"
  else
    echo "Web backend is not running"
  fi
}

iface_up() {
  NAME="$1"
  [ -n "$NAME" ] || { log "Interface name required"; return 1; }
  
  CONF_FILE="$CONF_DIR/${NAME}.conf"
  [ -f "$CONF_FILE" ] || { log "Config not found: $CONF_FILE"; return 1; }
  
  log "Starting interface: $NAME"
  ip link add dev "$NAME" type wireguard 2>>"$LOG_FILE"
  amneziawg-go setconf "$NAME" "$CONF_FILE" 2>>"$LOG_FILE"
  ip link set up dev "$NAME" 2>>"$LOG_FILE"
  
  # Set IP from config
  IP=$(grep '^Address' "$CONF_FILE" | head -n1 | cut -d' ' -f3)
  [ -n "$IP" ] && ip addr add "$IP" dev "$NAME" 2>>"$LOG_FILE"
  
  log "Interface $NAME started"
}

iface_down() {
  NAME="$1"
  [ -n "$NAME" ] || { log "Interface name required"; return 1; }
  
  log "Stopping interface: $NAME"
  ip link set down dev "$NAME" 2>>"$LOG_FILE"
  ip link delete dev "$NAME" 2>>"$LOG_FILE"
  log "Interface $NAME stopped"
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
