# Amnezia-UI for ASUSWRT-Merlin

[![Platform](https://img.shields.io/badge/platform-ASUSWRT--Merlin-blue.svg)](https://www.asuswrt-merlin.net)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/release/Sp0Xik/asuswrt-merlin-amnezia-ui.svg)](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases)

**AmneziaWG (WireGuard with DPI bypass) addon for ASUSWRT-Merlin routers**

Provides command-line and web interface management for AmneziaWG tunnels with advanced DPI circumvention technologies including CPS control and obfuscation presets (I1-I5, S1-S4, H1-H4).

## Installation

```sh
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install.sh | sh
```

## Quick Start

```sh
# Add configuration
amnezia-ui add /path/to/config.conf

# Start VPN interface  
amnezia-ui start amnezia0

# Start web interface
amnezia-ui web start
# Access at http://router-ip:8080

# Check status
amnezia-ui status
```

## Custom Scripts Support

Use `/jffs/amneziaui_custom/` directory for custom hooks:

- `firewall-start` - Run after firewall rules applied
- `pre-start` - Run before interface start
- `post-start` - Run after interface start

## Commands

- `install` - Install/reinstall addon
- `uninstall` - Remove addon
- `start [interface]` - Start interface
- `stop [interface]` - Stop interface
- `restart [interface]` - Restart interface
- `status` - Show status
- `add <config>` - Add config file
- `web start|stop|status` - Manage web interface

## Requirements

- ASUSWRT-Merlin 3004.388.x+
- Custom scripts enabled
- 10MB free space in `/jffs`

## Compatibility

- **Architecture**: ARMv7, ARMv8/AArch64, MIPS
- **Firmware**: Original Merlin, gnuton fork
- **Addons**: VPN Director, YazFi, Diversion, Skynet
