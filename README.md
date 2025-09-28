# Amnezia-UI v3.1 — ASUSWRT-Merlin plugin (Merlin + gnuton)

Badges: MIT | Platform: ASUSWRT-Merlin | Version: v3.1.0

Description
Amnezia-UI integrates AmneziaWG (WireGuard with DPI-bypass) into the router Web UI. Fully compatible with ASUSWRT-Merlin stock and gnuton’s fork. Supports AmneziaWG 1.5 CPS and presets I1–I5 (S1–S4, H1–H4 headers).

Key Features
- Web UI button in VPN Client table; easy add/start/stop configs
- AmneziaWG 1.5: CPS on/off, presets I1–I5, S1–S4, H1–H4
- Selective routing: per-domain/IP lists with ipset
- Universal CPU: ARMv7, ARMv8, MIPS
- One-line install and CLI tooling

Compatibility
- Firmware: 3004.388.x+ (Merlin and gnuton)
- Tested models: RT-AX88U, RT-AX86U, TUF-AX5400, RT-AC68U and others
- Works alongside: VPN Director, YazFi, Diversion, Skynet

Requirements
- ASUSWRT-Merlin firmware installed
- Entware (opkg)
- ~50 MB free in /opt during install
- Internet access to fetch components

Quick Installation
One-line (recommended):
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal-v31.sh | sh

Manual installation:
1) Dependencies
opkg update
opkg install jq ipset git-http ca-bundle

2) Fetch release (CI artifact tarball)
wget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz \
  https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/latest/download/asuswrt-merlin-amnezia-ui.tar.gz
mkdir -p /jffs/addons
cd /jffs/addons && tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz

3) Install and enable Web UI
mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui
chmod 0755 /jffs/scripts/amnezia-ui
/jffs/scripts/amnezia-ui install
service restart_httpd

How to Use
- Open router Web UI → VPN → VPN Client → press “Amnezia-UI”
- Fill fields:
  Interface: amnezia0
  Private/Public keys, Endpoint host:port, AllowedIPs (0.0.0.0/0 for all)
  Optional: S1–S4, H1–H4, CPS or preset I1–I5
- Add Config → Start/Stop

CLI
Start:   /jffs/scripts/amnezia-ui start amnezia0
Stop:    /jffs/scripts/amnezia-ui stop amnezia0
Status:  /jffs/scripts/amnezia-ui status [iface]
Add:     /jffs/scripts/amnezia-ui add /jffs/addons/amnezia-ui/conf/my.conf
Logs:    tail -f /tmp/amnezia-ui.log
Web:     /jffs/scripts/amnezia-ui web start|stop|status

Example (WG/AmneziaWG)
[Interface]
PrivateKey = <client_private>
Address    = 10.8.0.2/32

[Peer]
PublicKey  = <server_public>
Endpoint   = your-server.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

# Optional: Amnezia obfuscation
S1 = <key>
S2 = <key>
H1 = 1
H2 = 2
# or use preset marker line: I3

Troubleshooting
- Disk: df -h /opt
- Entware: opkg --version
- Install log: cat /tmp/amnezia-ui-install.log
- Interface: ip link show amnezia0
- Ping: ping 8.8.8.8
- Runtime logs: tail -f /tmp/amnezia-ui.log

Uninstall
/jffs/scripts/amnezia-ui stop-all
/jffs/scripts/amnezia-ui uninstall
service restart_httpd

Notes
- AmneziaWG 1.5 CPS and presets I1–I5 supported on both Merlin and gnuton.
- UI/backend shipped by installer; CI publishes tarball artifact.

License
MIT — see LICENSE

Acknowledgments
- AmneziaVPN team (amneziawg-go)
- ASUSWRT-Merlin community
- Testers and contributors
