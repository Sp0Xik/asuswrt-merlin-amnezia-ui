# Amnezia-UI for ASUSWRT-Merlin

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform](https://img.shields.io/badge/Platform-ASUSWRT--Merlin-blue.svg)
![Version](https://img.shields.io/badge/Version-Universal-green.svg)

## Description

**Amnezia-UI** is a user-friendly plugin for ASUSWRT-Merlin routers that integrates AmneziaWG (WireGuard with advanced obfuscation) directly into your router's web interface. Works with both original ASUSWRT-Merlin and gnuton's fork.

## Key Features

- **Easy Web Interface**: Manage AmneziaWG connections directly from your router's admin panel
- **Advanced Obfuscation**: Full support for S1/S2/S3/S4 keys and H1-H4 header obfuscation to bypass VPN blocks
- **Selective Routing**: Route specific websites or IP addresses through VPN while keeping local traffic direct
- **Universal Compatibility**: Works on ARMv7, ARMv8, and MIPS architectures
- **One-Click Installation**: Simple installer script handles everything automatically

## Compatibility

- **Firmware**: ASUSWRT-Merlin 3004.388.x and newer (including gnuton's fork)
- **Routers**: TUF-AX5400, RT-AX88U, RT-AX86U, RT-AC68U, and more
- **Other Addons**: Compatible with VPN Director, YazFi, Diversion, and other popular plugins

## Requirements

- ASUSWRT-Merlin firmware installed
- Entware package manager (usually pre-installed)
- 50MB free space in /opt during installation
- Internet connection for downloading components

## Quick Installation

### One-Line Installation (Recommended)

```bash
# Download and run the universal installer
curl -sSL https://raw.githubusercontent.com/Sp0Xik/asuswrt-merlin-amnezia-ui/main/install-universal.sh | sh
```

### Manual Installation

```bash
# Install dependencies
opkg update
opkg install make go git git-http ipset jq

# Download and extract
wget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz \
  https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/latest/download/asuswrt-merlin-amnezia-ui.tar.gz
tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz -C /jffs/addons

# Install and configure
mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui
chmod 0755 /jffs/scripts/amnezia-ui
sh /jffs/scripts/amnezia-ui install

# Restart web interface
service restart_httpd
```

## How to Use

1. After installation, navigate to **VPN → VPN Client** in your router's web interface
2. Click the **"Amnezia-UI"** button that appears in the VPN client table
3. Fill in your VPN connection details:
   - **Interface Name**: Choose a name (e.g., "amnezia0")
   - **Private Key**: Your client private key
   - **Public Key**: Server public key
   - **Endpoint**: Server address and port (e.g., "vpn.example.com:51820")
   - **Allowed IPs**: Which traffic to route ("0.0.0.0/0" for all traffic)
4. Optional: Configure obfuscation keys (S1, S2, S3, S4) if your server supports them
5. Optional: Set up selective routing for specific websites or IP addresses
6. Click **"Add Config"** to save your settings
7. Use Start/Stop buttons to control your VPN connection

## Configuration Example

```ini
[Interface]
PrivateKey = your_private_key_here
Address = 10.8.0.2/32

[Peer]
PublicKey = server_public_key_here
Endpoint = your-server.com:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

# Optional: Amnezia obfuscation
S1 = your_s1_key
S2 = your_s2_key
H1 = 1
H2 = 2
```

## Command Line Usage

```bash
# Start VPN connection
/jffs/scripts/amnezia-ui start amnezia0

# Stop VPN connection
/jffs/scripts/amnezia-ui stop amnezia0

# Check connection status
/jffs/scripts/amnezia-ui status amnezia0

# View logs
tail -f /tmp/amnezia-ui.log
```

## Troubleshooting

### Installation Issues

```bash
# Check available space
df -h /opt

# Verify Entware is working
opkg --version

# Check installation log
cat /tmp/amnezia-ui-install.log
```

### Connection Problems

```bash
# Verify interface is up
ip link show amnezia0

# Test connectivity
ping 8.8.8.8

# Check system logs
tail -f /tmp/amnezia-ui.log
```

## Uninstalling

```bash
# Stop all connections and remove plugin
/jffs/scripts/amnezia-ui stop-all
sh /jffs/scripts/amnezia-ui uninstall
service restart_httpd
```

## Support

- **Documentation**: [Wiki Pages](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/wiki)
- **Issues**: [GitHub Issues](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/discussions)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [AmneziaVPN Team](https://github.com/amnezia-vpn/amneziawg-go) for the core AmneziaWG implementation
- ASUSWRT-Merlin community for the excellent firmware foundation
- Contributors and testers for validating compatibility across different router models
