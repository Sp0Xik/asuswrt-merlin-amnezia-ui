# Amnezia-UI for ASUSWRT-Merlin
[![Platform](https://img.shields.io/badge/platform-ASUSWRT--Merlin-blue.svg)](https://www.asuswrt-merlin.net/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/release/Sp0Xik/asuswrt-merlin-amnezia-ui.svg)](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases)

AmneziaWG (WireGuard with DPI bypass) addon for ASUSWRT-Merlin routers
Provides command-line and web interface management for AmneziaWG tunnels with advanced DPI circumvention technologies including CPS control and obfuscation presets (I1-I5, S1-S4, H1-H4).

## 🚀 One-Command Installation (Zero manual steps)
Finally! True one-command installation — no more manual .asusrouter marker creation or compatibility issues!
```
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install.sh | sh
```
What happens automatically after install:
- Auto-detect Merlin and auto-create /jffs/.asusrouter marker (like YazFi/XRAYUI)
- Auto-install addon files and set permissions
- Auto-create services-start and firewall-start hooks
- Auto-start web UI on port 8080 and expose ASP page at /asp
- Auto-generate persistent ASUSWRT ASP integration and add VPN menu button
- Survives reboot — web UI starts automatically

## Quick Start (optional, everything auto-starts)
No commands required after install. If you want to manage manually:
```
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

## 🧩 Persistent VPN Menu Integration (XRAYUI-style)
We implement a real, automatic, persistent integration into the router's stock web UI, just like XRAYUI/YazFi/Diversion.
Two methods are used automatically by install scripts and hooks:
1. Overlay injection (preferred, persistent across reboots/updates)
   - We create /jffs/overlay/www/Advanced_VPN_Content.asp on first boot after update
   - We inject an Amnezia-UI button linking to /user_amneziaui.asp (mini page)
   - We bind-mount the overlay to /www/Advanced_VPN_Content.asp after httpd starts
2. Direct sed patch (fallback)
   - On every boot, if overlay cannot be applied, we sed-inject the link into /www/Advanced_VPN_Content.asp

Manual commands you can run (optional):
```
amnezia-ui install            # ensure ASP mini-page exists and inject links
amnezia-ui ui overlay         # overlay injections for homepage, VPN/Firewall, VPN.asp, menuTree.js
amnezia-ui ui patch           # direct sed fallback if overlay not available
```
Verification:
- Visit http://router-ip/Advanced_VPN_Content.asp — should include an Amnezia-UI link
- Click it — lands on /user_amneziaui.asp with embedded UI and external link

## 🧭 Mini-UI (userX.asp) — Universal Integration on Any Merlin Router
- File: /www/user_amneziaui.asp (created in overlay at /jffs/overlay/www when available)
- Contains an embedded iframe that opens the Amnezia-UI web interface at http://router-ip:8080/
- Provides a direct "Open full UI" button in a new tab
- A link to this page is injected into:
  - The router homepage (index.asp via overlay copy)
  - VPN and Firewall pages when present (Advanced_VPN_Content.asp, Advanced_Firewall_Content.asp)

## 🧨 New in v3.6.0 — Robust menu integration everywhere
- Add overlay/patch for /www/menuTree.js to insert global left-menu item "Amnezia-UI"
  - Supports both array-based and object-based menus; appends as fallback
- Add fallback quick-link injection into /www/User2.asp for legacy firmwares
- Auto-inject "Amnezia-UI" into the main VPN menu (VPN.asp) regardless of structure
  - Tries UL/LI lists after WireGuard/OpenVPN/VPNFusion; falls back to plain anchor near headers
- Keep previous Advanced_VPN_Content.asp / Advanced_Firewall_Content.asp injections

## ✨ Changelog
- v3.6.0
  - Overlay patch for /www/menuTree.js to add global "Amnezia-UI" entry
  - Fallback injection into /www/User2.asp
  - Robust VPN main menu injection regardless of submenu structure
  - VERSION bump to 3.6.0
- v3.5.1
  - Top-level VPN tab entry injection via VPN.asp overlay (preferred) with fallback
  - Installer updated to reference VPN.asp variable
- v3.5.0
  - Universal Mini-UI: auto-create /www/user_amneziaui.asp
  - Automatic homepage and VPN/Firewall link injection via overlay
  - Improved installer/uninstaller flow for UI integration

## Requirements
- ASUSWRT-Merlin 3004.388.x+
- Custom scripts enabled
- 10MB free space in /jffs
- Entware (auto-installed if missing)

## Troubleshooting
- If the menu button doesn’t appear, your firmware skin may use different markup. Adjust selectors in addons/amneziaui/amnezia-ui accordingly.
- Check logs: /tmp/amneziaui.log
- Ensure /jffs/.asusrouter exists

## License
MIT
