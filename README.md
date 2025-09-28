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
We now implement a real, automatic, persistent integration into the router's stock web UI, just like XRAYUI/YazFi/Diversion.
Two methods are used automatically by install scripts and hooks:
1. Overlay injection (preferred, persistent across reboots/updates)
   - We create /jffs/overlay/www/Advanced_VPN_Content.asp on first boot after update
   - We inject an Amnezia-UI button linking to /amneziaui/asp/index.asp
   - We bind-mount the overlay to /www/Advanced_VPN_Content.asp after httpd starts
2. Direct sed patch (fallback)
   - On every boot, if overlay cannot be applied, we sed-inject the link into /www/Advanced_VPN_Content.asp

Commands you can run manually (optional):
```
# Ensure ASP page exists
amnezia-ui web asp-create
# Status of ASP page
amnezia-ui web asp-status
# Force overlay bind-mount now
amnezia-ui ui overlay
# Apply direct patch now (fallback)
amnezia-ui ui patch
```
Verification:
- Visit http://router-ip/Advanced_VPN_Content.asp — the VPN page should include an Amnezia-UI menu item
- Click it — lands on /amneziaui/asp/index.asp with status badge and Web UI button
- Status auto-refreshes every 10 seconds

---
## 🧭 Mini-UI (userX.asp) — Universal Integration on Any Merlin Router
Starting v3.5.0 we auto-create an independent mini-page that appears as a separate submenu entry on all Merlin routers, even if the stock ASP structure is missing or customized by skins.

- File: /www/user_amneziaui.asp (created in overlay at /jffs/overlay/www when available)
- Contains a minimal embedded iframe that opens the Amnezia-UI web interface at http://router-ip:8080
- Also provides a direct "Open full UI" button in a new tab
- A link to this page is injected into:
  - The router homepage (index.asp via overlay copy)
  - VPN and Firewall pages when present (Advanced_VPN_Content.asp, Advanced_Firewall_Content.asp)
- Safe and persistent: uses overlay copies instead of modifying stock files directly, when possible

Manual commands (optional):
```
# Recreate mini UI page and reinject links
amnezia-ui install
# Inject links only (if page already exists)
amnezia-ui ui overlay
```

---
## ✨ What’s New in v3.5.0
- Universal Mini-UI: auto-create /www/user_amneziaui.asp with embedded iframe and external link
- Automatic homepage and VPN/Firewall link injection via overlay (fallback-safe)
- Improved installer/uninstaller flow for UI integration

Previous: v3.4.1
- Real router ASP integration: auto-generated ASP page at /amneziaui/asp/index.asp
- Automatic VPN menu button injection (overlay + sed fallback)
- Hooks created on install (services-start, init-start)
- Web UI auto-start and persistence improvements

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
