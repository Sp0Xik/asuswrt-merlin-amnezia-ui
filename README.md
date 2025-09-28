# Amnezia-UI for ASUSWRT-Merlin

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform](https://img.shields.io/badge/Platform-ASUSWRT--Merlin-blue.svg)
![Version](https://img.shields.io/badge/Version-Universal-green.svg)

## Description

**Amnezia-UI** is a production-ready plugin for ASUSWRT-Merlin firmware that integrates AmneziaWG (WireGuard with obfuscation) into the router's VPN interface. This universal system supports multiple architectures and provides enterprise-grade VPN functionality with advanced obfuscation techniques.

## Key Features

### Core Functionality
- **Complete Web UI** for AmneziaWG VPN management
- **Full AWG 2.0 Support**: S1/S2/S3/S4 keys and H1-H4 header obfuscation
- **Advanced Routing**: Selective routing via iptables/ipset (IP addresses and domains)
- **Seamless Integration**: Native button in ASUSWRT-Merlin VPN tab
- **Conflict Prevention**: Dynamic userN.asp assignment
- **Universal Compatibility**: Multi-architecture support (ARMv7/ARMv8/MIPS)

### Enterprise Features
- **Production Ready**: Automated builds and testing
- **CI/CD Pipeline**: GitHub Actions integration
- **Universal Installer**: One-script deployment
- **Comprehensive Monitoring**: Detailed logging and status reporting
- **Security Hardened**: Minimal attack surface, secure defaults

### Compatibility Matrix
- **Firmware**: ASUSWRT-Merlin 3004.388.x and newer
- **Architectures**: ARMv7, ARMv8-A, MIPS
- **Router Models**: TUF-AX5400, RT-AX88U, RT-AX86U, and more
- **Integration**: Compatible with VPN Director, WireGuard, XRAYUI, YazFi, Diversion

## System Requirements

### Essential Prerequisites
- ASUSWRT-Merlin firmware (tested on 3004.388.9_2+)
- Entware package manager installed
- Minimum 50MB free space in /opt for compilation
- Internet connectivity for dependency download

### Architecture Support
| Architecture | Status | Examples |
|-------------|--------|-----------|
| ARMv7 | ✅ Full Support | TUF-AX5400, RT-AC86U |
| ARMv8-A | ✅ Full Support | RT-AX88U, RT-AX86U |
| MIPS | ✅ Full Support | RT-AC68U variants |

## Quick Installation

### Method 1: Universal Installer (Recommended)
```bash
# Download and run universal installer
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal.sh | sh
```

### Method 2: Manual Installation
```bash
# Install Entware dependencies
opkg update
opkg install make go git git-http ipset jq

# Download and extract plugin
wget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz \
  https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/latest/download/asuswrt-merlin-amnezia-ui.tar.gz

tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz -C /jffs/addons

# Install and configure
mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui
chmod 0755 /jffs/scripts/amnezia-ui
sh /jffs/scripts/amnezia-ui install

# Restart web interface
service restart_httpd

# Verify installation
cat /tmp/amnezia-ui-install.log
```

## Configuration Guide

### Web Interface Access
1. Navigate to `http://[router-ip]/Advanced_VPNClient_Content.asp`
2. Click "Amnezia-UI" button in VPN client table
3. Configure VPN settings in the dedicated interface

### VPN Configuration Parameters
#### Required Settings
- **Interface Name**: Unique identifier (e.g., `amnezia0`)
- **Private Key**: Client private key
- **Public Key**: Server public key  
- **Endpoint**: Server address and port
- **Allowed IPs**: Routing destinations

#### Optional Advanced Settings
- **Preshared Key**: Additional security layer
- **S1/S2/S3/S4 Keys**: AWG obfuscation parameters
- **H1-H4 Headers**: Header obfuscation ranges
- **Selective Routing**: Custom routing rules
- **Obfuscation**: Enable AWG traffic obfuscation

### Example Configuration
```ini
[Interface]
PrivateKey = your_private_key_here
Address = 10.8.0.2/32

[Peer] 
PublicKey = server_public_key_here
Endpoint = your-server.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

# AWG Obfuscation (optional)
Jc = 4
Jmin = 40
Jmax = 70
S1 = your_s1_key
S2 = your_s2_key
H1 = 1
H2 = 2
H3 = 3
H4 = 4
```

## Operations Management

### Service Control
```bash
# Start VPN connection
/jffs/scripts/amnezia-ui start amnezia0

# Stop VPN connection  
/jffs/scripts/amnezia-ui stop amnezia0

# Check connection status
/jffs/scripts/amnezia-ui status amnezia0

# Restart service
/jffs/scripts/amnezia-ui restart amnezia0
```

### Monitoring and Diagnostics
```bash
# View configuration
cat /jffs/amnezia-ui/configs/amnezia0.conf

# Check connection status
ping 8.8.8.8  # Should route through VPN

# View firewall rules
cat /jffs/amnezia-ui_custom/firewall_client
cat /jffs/amnezia-ui_custom/dnsmasq_rules.conf

# Check VPN Director compatibility
nvram get vpndirector_rulelist

# View system logs
tail -f /tmp/amnezia-ui.log
```

## Advanced Features

### Universal Architecture Support
The system automatically detects and supports:
- **ARMv7**: 32-bit ARM processors
- **ARMv8-A**: 64-bit ARM processors  
- **MIPS**: MIPS-based routers

### CI/CD Integration
Automated build pipeline provides:
- Cross-architecture compilation
- Automated testing
- Release package generation
- Dependency verification

### Production Hardening
- Minimal dependency footprint
- Secure default configurations
- Comprehensive error handling
- Automatic cleanup procedures

## Troubleshooting

### Common Issues

#### Installation Failures
```bash
# Check available space
df -h /opt

# Verify Entware
opkg --version

# Check dependencies  
which make go git jq
```

#### Connection Problems
```bash
# Verify interface status
ip link show amnezia0

# Check routing table
ip route show table main

# Verify DNS resolution
nslookup google.com
```

#### Performance Issues
```bash
# Monitor bandwidth usage
iftop -i amnezia0

# Check CPU utilization
top | grep amnezia

# View memory usage
cat /proc/meminfo
```

## Uninstallation

### Complete Removal
```bash
# Stop all connections
/jffs/scripts/amnezia-ui stop-all

# Uninstall plugin
sh /jffs/scripts/amnezia-ui uninstall

# Restart web interface
service restart_httpd

# Verify removal
cat /tmp/amnezia-ui-uninstall.log
```

## Development Information

### Technical Specifications
- **AmneziaWG Version**: v0.2.15+
- **Go Runtime**: 1.19+
- **Build System**: Make-based with cross-compilation
- **Package Format**: Compressed tar.gz with checksums

### Integration Details
- **Compatibility**: XRAYUI, YazFi, Diversion (isolated paths/ports)
- **VPN Director**: Full compatibility maintained
- **Web Interface**: Dynamic userN.asp allocation
- **Logging**: Comprehensive error and status logging

## Contributing

### Bug Reports
Please report issues with:
- Router model and firmware version
- Installation logs (`/tmp/amnezia-ui-install.log`)
- Error messages and symptoms
- Network configuration details

### Development
1. Fork the repository
2. Create feature branch
3. Test on target hardware
4. Submit pull request with detailed description

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [AmneziaVPN Team](https://github.com/amnezia-vpn/amneziawg-go) for the core AmneziaWG implementation
- ASUSWRT-Merlin community for firmware foundation
- Contributors and testers for platform validation

## Support

- **Documentation**: [Wiki Pages](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/wiki)
- **Issues**: [GitHub Issues](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/discussions)

---

**Status**: Production Ready | **Maintenance**: Active | **Community**: Growing
