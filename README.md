# Amnezia-UI for ASUSWRT-Merlin

Amnezia-UI is a custom addon for ASUSWRT-Merlin firmware, designed to manage AmneziaWG (WireGuard with obfuscation) VPN tunnels on ASUS routers. It provides a web interface to configure, start, stop, and manage AmneziaWG connections with selective routing (split-tunneling) for specific IPs or domains, ensuring compatibility with Merlin's built-in WireGuard and VPN Director.

## Features
- **Full AmneziaWG Support**: Utilizes `amneziawg-go` for complete WireGuard functionality with S1/S2 obfuscation keys to bypass DPI (no fallback to standard wg-quick).
- **Selective Routing (Split-Tunneling)**: Route specific IPs or domains through the VPN while the rest of the traffic uses the regular internet, using iptables and dnsmasq (similar to advanced Merlin VPN addons).
- **Web Interface**: Manage VPN configurations via a user-friendly UI at `http://<router_ip>/user/amnezia-ui/`.
- **Compatibility**: Works alongside Merlin's built-in WireGuard (wg0/wg1) and VPN Director without conflicts.
- **Entware Integration**: Requires Entware for dependencies (`make`, `golang`, `ipset`).

## Requirements
- ASUS router with ASUSWRT-Merlin firmware (tested on 386.1+).
- JFFS enabled (Administration > System > Enable JFFS).
- Entware installed via `amtm` (for `make`, `golang`, `ipset`).
- Sufficient storage in `/opt` (~100MB for `golang`, check with `df -h /opt`).

## Installation
1. **Install Entware** (if not already installed):
   ```bash
   ssh <router_ip>
   amtm
   # Follow amtm to install Entware
   opkg update
   opkg install make golang ipset
   df -h /opt  # Ensure ~100MB free
   make --version
   go version

Download and Install Amnezia-UI:
bashwget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/latest/download/asuswrt-merlin-amnezia-ui.tar.gz
rm -rf /jffs/addons/amnezia-ui
tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz -C /jffs/addons
mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui
chmod 0755 /jffs/scripts/amnezia-ui
sh /jffs/scripts/amnezia-ui install

Access the Web UI:
bashservice restart_httpd
Open http://<router_ip>/user/amnezia-ui/ in your browser.

Usage

Add a VPN Config:

In the UI, fill in:

Interface Name: e.g., amnezia0.
Private Key, Public Key, Endpoint: From your AmneziaWG server.
Allowed IPs: e.g., 0.0.0.0/0 for full tunnel or specific IPs.
Preshared Key (optional): For additional security.
S1/S2 Keys (optional): 32-byte base64 keys for AmneziaWG obfuscation.
Selective Routing Rules (optional): Comma-separated IPs/domains (e.g., 8.8.8.8,example.com,192.168.1.0/24).
Enable Obfuscation: Check to enable S1/S2 obfuscation.


Click "Add Config" to save.


Manage VPNs:

In the "Server List" section, use buttons to Start, Stop, or Delete configurations.
Selective routing: Traffic to specified IPs/domains goes through the VPN; others use the regular internet.


Verify:

Check generated files:
bashcat /jffs/amnezia-ui/configs/amnezia0.conf  # VPN config with S1/S2
cat /jffs/amnezia-ui_custom/firewall_client  # iptables rules
cat /jffs/amnezia-ui_custom/dnsmasq_rules.conf  # domain rules

Test routing:
bashping 8.8.8.8  # Should go through VPN if in rules
ping 1.1.1.1  # Should go through regular internet

Verify Merlin WG: In Merlin UI > VPN > WireGuard Client (should work).
Verify VPN Director: nvram get vpndirector_rulelist (unchanged).



Troubleshooting

Build Failure: If installation fails with "Failed to build amneziawg-go":

Run opkg install make golang ipset.
Check /opt space: df -h /opt (~100MB needed).
Ensure Entware is installed via amtm.


UI Not Loading: Run service restart_httpd and check http://<router_ip>/user/amnezia-ui/.
Routing Issues: Verify /jffs/amnezia-ui_custom/firewall_client and dnsmasq_rules.conf. Run service restart_dnsmasq.

Uninstallation
bash/jffs/scripts/amnezia-ui uninstall
Note: Dependencies (make, golang, ipset) are not removed to avoid breaking other addons.
Contributing
Submit issues or PRs at https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui. Tested on TUF-AX5400 (ARMv7).
License
MIT License. See LICENSE for details.
