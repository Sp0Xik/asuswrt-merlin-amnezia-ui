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

## Repository Structure
```
asuswrt-merlin-amnezia-ui/
├── addons/amneziaui/          # Main addon directory
│   ├── amnezia-ui             # Main control script
│   ├── amneziawg-go           # AmneziWG binary (architecture-specific)
│   ├── web/                   # Web interface files
│   │   └── asp/               # ASP-like status page
│   └── configs/               # Configuration files directory
├── install.sh                 # Installation script
└── README.md                  # This file
```

## Custom Scripts Support
Use /jffs/amneziaui_custom/ directory for custom hooks:
- firewall-start — Run after firewall rules applied
- pre-start — Run before interface start
- post-start — Run after interface start

## Commands
- install — Install/reinstall addon
- uninstall — Remove addon
- start [interface] — Start interface
- stop [interface] — Stop interface
- restart [interface] — Restart interface
- status — Show status
- add <config_file> — Add config file
- web start|stop|status — Manage web interface

## Requirements
- ASUSWRT-Merlin 3004.388.x+
- Custom scripts enabled
- 10MB free space in /jffs

No manual compatibility setup needed — handled automatically.

## Features
### DPI Bypass Technology
- Advanced obfuscation presets (I1-I5, S1-S4, H1-H4)
- CPS (Connection Per Second) control
- Header modification and junk packet injection
- Sleep interval randomization

### Management Interfaces
- Command Line: Full-featured CLI for all operations
- Web Interface: Browser-based management on port 8080 (+ ASP status page)
- Configuration Management: Automatic config file handling
- Status Monitoring: Real-time connection status (status.json)

### Integration
- Seamless integration with ASUSWRT-Merlin firmware
- Compatible with existing VPN and firewall addons
- Custom script hooks for advanced users
- Automatic startup and shutdown handling
- Smart compatibility detection and setup 🚀
