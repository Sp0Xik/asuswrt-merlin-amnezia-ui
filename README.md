# Amnezia-UI for ASUSWRT-Merlin

[![Platform](https://img.shields.io/badge/platform-ASUSWRT--Merlin-blue.svg)](https://www.asuswrt-merlin.net/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/release/Sp0Xik/asuswrt-merlin-amnezia-ui.svg)](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases)

**AmneziaWG 1.5** (WireGuard with ultimate DPI bypass) addon for ASUSWRT-Merlin routers

🎯 **Native ASP Web Interface** - No external Node.js server needed  
🚀 **Complete v4.0.0 Rewrite** - Modern ASP-based UI integrated directly into router firmware  
🛡️ **AmneziaWG 1.5** - Latest DPI circumvention with advanced obfuscation presets  
⚡ **Ultimate DPI Bypass** - I1-I5, S1-S4, H1-H4 presets + customizable parameters  
🔧 **Zero Configuration** - Auto-installs, auto-configures, survives reboots  

## 🚀 One-Command Installation

```bash
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install.sh | sh
```

### What Happens Automatically:
- ✅ Auto-detect ASUSWRT-Merlin and create `/jffs/.asusrouter` marker
- ✅ Download and install AmneziaWG 1.5 binaries
- ✅ Create native ASP web interface pages
- ✅ Integrate VPN menu buttons across all firmware pages
- ✅ Setup automatic startup hooks (services-start, firewall-start)
- ✅ Configure persistent overlay system for firmware updates
- ✅ Auto-start web interface - accessible immediately

## 🎯 Native ASP Web Interface (v4.0.0)

**Revolutionary Change**: No more external Node.js server! The entire web interface is now implemented as native ASUSWRT ASP pages.

### Access Points:
- **Main UI**: `http://router-ip/user_amneziaui.asp`
- **Config Manager**: `http://router-ip/user_amneziaui_configs.asp`
- **Quick Status**: Available from VPN menu in router's native interface

### Integration Locations:
- 📋 **VPN Menu** - Direct "Amnezia-UI" button in main VPN section
- 🏠 **Homepage** - Quick access link from main router page
- ⚙️ **Left Navigation** - Global menu item via menuTree.js injection
- 🔧 **Advanced Pages** - Links in VPN/Firewall configuration pages

## 🛡️ AmneziaWG 1.5 Features

### DPI Bypass Presets:
- **I1-I5**: Intermediate obfuscation levels
- **S1-S4**: Stealth modes with advanced packet manipulation
- **H1-H4**: High-security presets with maximum obfuscation

### Advanced Parameters:
- `Jc` (Junk packet count): 3-10 packets
- `Jmin/Jmax` (Junk size range): 50-1000 bytes
- `S1/S2` (Init packet sizes): Custom handshake obfuscation
- `H1-H4` (Header transformations): Advanced DPI evasion

## 📱 Quick Start

After installation, everything starts automatically. Optional manual management:

```bash
# Configuration management
amnezia-ui add /path/to/config.conf
amnezia-ui remove config-name
amnezia-ui list

# Interface control
amnezia-ui start amnezia0
amnezia-ui stop amnezia0
amnezia-ui status

# Web interface control (native ASP - no external server)
amnezia-ui install    # Reinstall ASP pages
amnezia-ui uninstall  # Remove integration
```

## 🔧 Migration from v3.x

**Important**: v4.0.0 completely replaces the external web server architecture.

### Automatic Migration:
1. Old Node.js web server is automatically stopped and disabled
2. Existing configurations are migrated to new format
3. ASP-based interface is installed and activated
4. All integrations are updated to new architecture

### Manual Migration (if needed):
```bash
# Clean old installation
amnezia-ui uninstall

# Remove old files
rm -rf /jffs/addons/amneziaui/web/
rm -f /jffs/addons/amneziaui/*v31*

# Reinstall v4.0.0
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install.sh | sh
```

## 🎛️ Configuration Examples

### High DPI Bypass (Recommended)
```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.66.66.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = your-server.com:51820
AllowedIPs = 0.0.0.0/0
# Ultimate DPI bypass
Jc = 7
Jmin = 50
Jmax = 1000
S1 = 150
S2 = 200
H1 = 1
H2 = 2
H3 = 3
H4 = 4
```

### Stealth Mode
```ini
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.66.66.2/32

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = your-server.com:443
AllowedIPs = 0.0.0.0/0
# Stealth preset S4
Jc = 10
Jmin = 100
Jmax = 500
S1 = 100
S2 = 150
```

## 📋 Supported Routers

### Fully Tested:
- **RT-AX88U** (3004.388.x)
- **RT-AX86U** (3004.388.x+)
- **RT-AC88U** (386.x+)
- **RT-AC68U** (386.x+)

### Compatible (reported working):
- All ASUSWRT-Merlin 3004.388.x+ routers
- Most 386.x routers with custom scripts enabled

## 🔧 Requirements

- **ASUSWRT-Merlin**: 3004.388.x+ (recommended) or 386.x+
- **Custom Scripts**: Enabled (`Administration → System → Enable custom scripts and configs`)
- **Storage Space**: 15MB free in `/jffs`
- **Entware**: Auto-installed if missing

## 🐛 Troubleshooting

### Common Issues:

**Menu buttons not appearing:**
```bash
# Reinstall ASP integration
amnezia-ui install

# Check logs
tail -f /tmp/amneziaui.log
```

**Interface won't start:**
```bash
# Check configuration
amnezia-ui list
amnezia-ui status

# Restart manually
amnezia-ui restart amnezia0
```

**Web interface not accessible:**
- Native ASP pages should be at `/user_amneziaui.asp`
- Check if httpd is running: `pidof httpd`
- Verify `/jffs/.asusrouter` exists

### Debug Information:
```bash
# System status
amnezia-ui status

# Configuration list
amnezia-ui list

# Check logs
cat /tmp/amneziaui.log

# Check integration
ls -la /www/user_amneziaui*
```

## 📈 Version History

### v4.0.0 (Latest) - Complete Rewrite
- ✨ **Native ASP Web Interface** - No external Node.js server
- ⚡ **AmneziaWG 1.5** - Latest DPI circumvention technology
- 🎯 **Ultimate DPI Bypass** - Full I/S/H preset support
- 🔧 **Automatic Migration** - Seamless upgrade from v3.x
- 📱 **Enhanced Integration** - Better menu placement and persistence
- 🛡️ **Improved Security** - No external web server vulnerabilities

### v3.6.0 (Legacy)
- Menu integration improvements
- VPN.asp overlay support
- menuTree.js global navigation

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Questions?** Open an [issue](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/issues) or check [releases](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases) for updates.
