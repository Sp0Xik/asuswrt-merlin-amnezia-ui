# Amnezia-UI for ASUSWRT-Merlin
[![Platform](https://img.shields.io/badge/platform-ASUSWRT--Merlin-blue.svg)](https://www.asuswrt-merlin.net/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/release/Sp0Xik/asuswrt-merlin-amnezia-ui.svg)](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases)

AmneziaWG (WireGuard with DPI bypass) addon for ASUSWRT-Merlin routers
Provides command-line and web interface management for AmneziaWG tunnels with advanced DPI circumvention technologies including CPS control and obfuscation presets (I1-I5, S1-S4, H1-H4).

## 🚀 One-Command Installation (Zero manual steps)
Finally! True one-command installation — no more manual .asusrouter marker creation or compatibility issues!
```bash
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install.sh | sh
```
What happens automatically after install:
- Auto-detect Merlin and auto-create /jffs/.asusrouter marker (like YazFi/XRAYUI)
- Auto-install addon files and set permissions
- Auto-create services-start and firewall-start hooks
- Auto-start web UI on port 8080 and expose ASP page at /asp
- Auto-start default interface skeleton and emit status
- Survives reboot — web UI starts automatically

## Quick Start (optional, everything auto-starts)
No commands required after install. If you want to manage manually:
```sh
# Add configuration (optional)
amnezia-ui add /path/to/config.conf
# Start/Stop interface manually (optional)
amnezia-ui start amnezia0
amnezia-ui stop amnezia0
# Web UI control (already running)
amnezia-ui web status
```
Web UI: http://router-ip:8080
ASP status page: http://router-ip:8080/asp

---

## 🧩 Integrating a persistent Amnezia-UI button into the ASUSWRT VPN menu (XRAYUI-style)
This section shows how to add a visual link/button to the stock VPN menu on any Merlin firmware so it survives reboots and most firmware updates.

There are two approaches:

1) Overlay injection (preferred; similar to XRAYUI)
- Create an overlay folder and an init script to bind-mount a patched ASP after httpd starts.
- Does not modify stock files on flash; can be reverted by removing the mount.

2) Direct patch (quick and dirty; not persistent across updates)
- sed/awk injects a link into /www/Advanced_VPN_Content.asp at boot.
- May need re-apply after firmware updates.

### Files provided in this repo
- addons/amneziaui/web/asp/index.asp — lightweight status/landing page with auto-refresh and button to open Web UI
- addons/amneziaui/amnezia-ui — writes ASP page, starts httpd on port 8080, exposes /asp
- addons/amneziaui/hook/README.md — quick reference for menu injection

### 1) Overlay injection (persistent)
Create /jffs/scripts/init-start to apply an overlay that adds a menu item:
```sh
#!/bin/sh
# /jffs/scripts/init-start
# Ensure Amnezia-UI web started and ASP exists
/jffs/addons/amneziaui/amnezia-ui web start >/dev/null 2>&1 &

# Wait for stock httpd and /www to be ready
sleep 5

# Prepare overlay dir
OLY=/jffs/overlay/www
SRC=/www
mkdir -p "$OLY"

# Copy original once if not present
if [ ! -f "$OLY/Advanced_VPN_Content.asp" ]; then
  cp -f "$SRC/Advanced_VPN_Content.asp" "$OLY/"
  # Inject menu link: add Amnezia-UI under VPN menu like XRAYUI
  sed -i 's|id="VPNMenu"|id="VPNMenu"><li><a href="/amneziaui/asp/index.asp">Amnezia-UI</a></li>|' \
    "$OLY/Advanced_VPN_Content.asp"
fi

# Bind-mount overlay file so UI shows the button
mount -o bind "$OLY/Advanced_VPN_Content.asp" "$SRC/Advanced_VPN_Content.asp"
```
Make executable:
```sh
chmod +x /jffs/scripts/init-start
```
This approach persists across reboots. After firmware updates, the first boot re-copies the new base file and re-injects the link.

### 2) Direct patch at boot (non-overlay; simpler)
Add to /jffs/scripts/services-start:
```sh
#!/bin/sh
# Start web and ASP
/jffs/addons/amneziaui/amnezia-ui web start >/dev/null 2>&1 &
# Delay to let httpd come up
sleep 5
# Inject a link into VPN menu every boot
sed -i 's|id="VPNMenu"|id="VPNMenu"><li><a href="/amneziaui/asp/index.asp">Amnezia-UI</a></li>|' \
  /www/Advanced_VPN_Content.asp || true
```
Make executable:
```sh
chmod +x /jffs/scripts/services-start
```

### ASP page expectations
- Title: Amnezia-UI (AmneziaWG)
- Elements: service status badge (RUNNING/STOPPED), button/link to Web UI (/), optional link to http://router.asus.com:8080
- Auto-refresh via meta refresh and JS to probe /status endpoint

The repository script generates addons/amneziaui/web/asp/index.asp automatically. If you replace it, keep the same path.

### Verification
- Visit http://router-ip/Advanced_VPN_Content.asp — the VPN page should include an Amnezia-UI menu item
- Click it — you land on /amneziaui/asp/index.asp served by our httpd root on port 8080 via reverse path
- The page shows current service state and a button to open full web UI

If you don’t see the link, verify the sed pattern matches your firmware’s markup. Some skins use different IDs; adapt the selector accordingly.

---

## Changelog
- v3.4.0
  - Web/ASP: added index.asp with status badge, auto-refresh, and UI buttons
  - Web control: httpd start/stop/status and autostart hook
  - Docs: persistent VPN menu integration (overlay and direct patch), examples and hooks
  - Misc: improved Merlin detection and directory bootstrap
- v3.3.x and earlier — initial releases
