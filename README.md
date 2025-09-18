Amnezia-UI for ASUSWRT-Merlin
Amnezia-UI is a plugin for ASUSWRT-Merlin firmware, integrating AmneziaWG (WireGuard with obfuscation) into the router's VPN tab. It supports AWG 2.0 (S3/S4, H1-H4), selective routing (IP/domains), and is compatible with Merlin's VPN Director and WireGuard.
Features

Web UI for managing AmneziaWG VPN configurations.
Supports S1/S2/S3/S4 keys, H1-H4 ranges, and obfuscation.
Selective routing via iptables/ipset (IP addresses or domains).
Button in VPN tab (Advanced_VPNClient_Content.asp).
Dynamic assignment of userN.asp to avoid conflicts.
Compatible with Merlin 3004.388.9_2, ARMv7 (e.g., TUF-AX5400).
Minimal dependencies: ipset, jq (runtime); make, go, git (build).

Requirements

ASUSWRT-Merlin firmware (tested on 3004.388.9_2).
Entware installed (opkg package manager).
~50MB free space in /opt for compilation.

Installation

Install Entware dependencies:opkg update
opkg install make go git git-http ipset jq


Download and extract the plugin:wget -O /tmp/asuswrt-merlin-amnezia-ui.tar.gz https://github.com/Sp0Xik/asuswrt-merlin-amnezia-ui/releases/download/v0.2.2/asuswrt-merlin-amnezia-ui.tar.gz
tar -xzf /tmp/asuswrt-merlin-amnezia-ui.tar.gz -C /jffs/addons


Install the plugin:mv /jffs/addons/amnezia-ui/amnezia-ui /jffs/scripts/amnezia-ui
chmod 0755 /jffs/scripts/amnezia-ui
sh /jffs/scripts/amnezia-ui install
service restart_httpd


Check installation log:cat /tmp/amnezia-ui-install.log



Usage

Open http://192.168.50.1/Advanced_VPNClient_Content.asp.
Click "Amnezia-UI" in the VPN client table (opens http://192.168.50.1/userN.asp).
Add a VPN config:
Interface Name: e.g., amnezia0
Private Key, Public Key, Endpoint, Allowed IPs: Required.
Preshared Key, S1/S2/S3/S4, H1-H4, Selective Routing Rules: Optional.
Enable Obfuscation: Check for AWG obfuscation (S1–S4, H1-H4).


Click "Add Config", then use "Start", "Stop", or "Delete" in the server list.

Testing

Verify config:cat /jffs/amnezia-ui/configs/amnezia0.conf


Start VPN:/jffs/scripts/amnezia-ui start amnezia0
ping 8.8.8.8  # Should go through VPN


Check firewall rules:cat /jffs/amnezia-ui_custom/firewall_client
cat /jffs/amnezia-ui_custom/dnsmasq_rules.conf


Check VPN Director (unchanged):nvram get vpndirector_rulelist



Uninstallation
sh /jffs/scripts/amnezia-ui uninstall
service restart_httpd
cat /tmp/amnezia-ui-uninstall.log

Notes

Compiles amneziawg-go v0.2.15 (https://github.com/amnezia-vpn/amneziawg-go).
Auto-removes build dependencies (make, go, git) if unused by other addons.
Compatible with XRAYUI, YazFi, Diversion (separate paths/ports).
Logs errors to /tmp/amnezia-ui-install.log or /tmp/amnezia-ui-uninstall.log.

License
MIT License (see LICENSE file).
