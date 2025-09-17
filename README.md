Amnezia-UI for ASUSWRT-Merlin
Amnezia-UI is a custom addon for ASUSWRT-Merlin firmware, designed to manage AmneziaWG (WireGuard with obfuscation) VPN tunnels on ASUS routers. It provides a web interface to configure, start, stop, and manage AmneziaWG connections with selective routing (split-tunneling) for specific IPs or domains, ensuring compatibility with Merlin's built-in WireGuard and VPN Director.
Features

Full AmneziaWG Support: Utilizes amneziawg-go for complete WireGuard functionality with S1/S2 obfuscation keys to bypass DPI (no fallback to standard wg-quick).
Selective Routing (Split-Tunneling): Route specific IPs or domains through the VPN while the rest of the traffic uses the regular internet, using iptables and dnsmasq.
Web Interface: Manage VPN configurations via a user-friendly UI at http://<router_ip>/user/amnezia-ui/.
Compatibility: Works alongside Merlin's built-in WireGuard (wg0/wg1) and VPN Director without conflicts.
Entware Integration: Requires Entware for dependencies (make, go, ipset, git).

Requirements

ASUS router with ASUSWRT-Merlin firmware (tested on 3004.388.9_2, TUF-AX5400).
JFFS enabled (Administration > System > Enable JFFS).
Entware installed via amtm (for make, go, ipset, git).
~50MB free in /opt (check with df -h /opt).

Dependencies
During installation, the script checks and installs only missing dependencies:

make: For building amneziawg-go.
go: For compiling Go code.
ipset: For domain-based selective routing.
git: For cloning the AmneziaWG repository.

These are installed via opkg install if absent. During uninstallation, dependencies are removed only if not used by other addons or Merlin (e.g., VPN Director for ipset). Check /tmp/amnezia-ui-uninstall.log for details.
Installation

Install Entware (if not already installed):
ssh <router_ip>
amtm
# Follow amtm to install Entware
opkg update
df -h /opt  # Ensure ~50MB free


Download and Install Amnezia-UI:
wget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/latest/download/asuswrt-merlin-amnezia-ui.tar.gz
rm -rf /jffs/addons/amnezia-ui
tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz -C /jffs/addons
# Check archive structure
ls -l /jffs/addons/amnezia-ui/
mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui 2>/dev/null || mv /jffs/addons/amnezia-ui/scripts/amnezia-ui /jffs/scripts/amnezia-ui
chmod 0755 /jffs/scripts/amnezia-ui
sh /jffs/scripts/amnezia-ui install


Access the Web UI:
service restart_httpd

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
Example Config (/jffs/amnezia-ui/configs/amnezia0.conf):[Interface]
PrivateKey = <your_private_key>
Address = 10.0.0.2/32
DNS = 8.8.8.8

[Peer]
PublicKey = <server_public_key>
Endpoint = <server_ip>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
PresharedKey = <psk>
S1 = <32-byte_base64_key>
S2 = <32-byte_base64_key>
# Amnezia Obfuscation enabled (S1/S2 keys supported)




Manage VPNs:

In the "Server List" section, use buttons to Start, Stop, or Delete configurations.
Selective routing: Traffic to specified IPs/domains goes through the VPN; others use the regular internet.


Verify:

Check generated files:cat /jffs/amnezia-ui/configs/amnezia0.conf
cat /jffs/amnezia-ui_custom/firewall_client
cat /jffs/amnezia-ui_custom/dnsmasq_rules.conf


Test routing:ping 8.8.8.8  # Through VPN if in rules
ping 1.1.1.1  # Through internet


Verify Merlin WG: In Merlin UI > VPN > WireGuard Client (should work).
Verify VPN Director: nvram get vpndirector_rulelist (unchanged).



Known Issues

Build Failure: If "Failed to build amneziawg-go":
Check /tmp/amneziawg-build.log for errors.
Ensure make, go, ipset, git installed (opkg install make go ipset git).
Verify ~50MB free in /opt (df -h /opt).
Run amtm to install Entware if missing.


UI Not Loading: Run service restart_httpd and check http://<router_ip>/user/amnezia-ui/.
Routing Issues: Verify /jffs/amnezia-ui_custom/firewall_client and dnsmasq_rules.conf. Run service restart_dnsmasq.
Uninstallation: If packages are not removed, check /tmp/amnezia-ui-uninstall.log for details (e.g., if used by other addons/Merlin).

Uninstallation
/jffs/scripts/amnezia-ui uninstall

Dependencies (make, go, ipset, git) are removed only if not used by other addons or Merlin. Check /tmp/amnezia-ui-uninstall.log for details.
Contributing
Submit issues or PRs at https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui. Tested on TUF-AX5400 (ARMv7).
License
MIT License. See LICENSE for details.
