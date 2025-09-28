#!/bin/sh
# Universal installer for Amnezia-UI
# Universal production-ready system: 30 models, auto-detection, GitHub-powered, intelligent fallback.
set -e

if [ "$(id -u)" != "0" ]; then
  echo "Please run as root (admin)." >&2
  exit 1
fi

JFFS="/jffs"
SCRIPTS_DIR="$JFFS/scripts"
LAUNCHER="$PWD/amnezia-ui-universal.sh"

# If launched from tarball root, the launcher may be in current dir; otherwise, fetch it
if [ ! -f "$LAUNCHER" ]; then
  TMP_LAUNCHER="/tmp/amnezia-ui-universal.sh"
  echo "Fetching universal launcher..."
  wget -O "$TMP_LAUNCHER" "https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/amnezia-ui-universal.sh"
  chmod 0755 "$TMP_LAUNCHER"
  LAUNCHER="$TMP_LAUNCHER"
fi

mkdir -p "$SCRIPTS_DIR"
cp -f "$LAUNCHER" "$SCRIPTS_DIR/amnezia-ui-universal.sh"
chmod 0755 "$SCRIPTS_DIR/amnezia-ui-universal.sh"

# Run install via launcher
sh "$SCRIPTS_DIR/amnezia-ui-universal.sh" install

echo "Installation complete. Open router VPN Client page and click Amnezia-UI."
