# Configuration Directory

This directory stores AmneziaWG configuration files.

## Contents

Configuration files for AmneziWG tunnels with DPI bypass settings.

### File Format

Configuration files should be in standard WireGuard format with AmneziWG extensions:

```ini
[Interface]
PrivateKey = <private_key>
Address = 10.0.0.2/32
DNS = 1.1.1.1, 1.0.0.1

# AmneziWG DPI Bypass Settings
Jc = 4
Jmin = 50
Jmax = 1000
S1 = 96
S2 = 15
H1 = 834291022
H2 = 611174849
H3 = 924608732
H4 = 271012752

[Peer]
PublicKey = <server_public_key>
Endpoint = <server_ip>:<port>
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

### Adding Configurations

Use the command line tool to add configurations:

```bash
amnezia-ui add /path/to/config.conf
```

### Configuration Management

- Files are automatically copied to this directory when added
- Each interface should have its own .conf file
- Naming convention: `interface_name.conf` (e.g., `amnezia0.conf`)
- Configuration files are used by the amnezia-ui script to start/stop interfaces

### DPI Bypass Parameters

- **Jc**: Junk packet count
- **Jmin/Jmax**: Junk packet size range
- **S1/S2**: Sleep intervals
- **H1-H4**: Header modification values

These parameters help bypass Deep Packet Inspection (DPI) systems.
