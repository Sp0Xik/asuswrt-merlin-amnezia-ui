<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Amnezia-UI</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input[type="text"], input[type="checkbox"], select { width: 100%; max-width: 400px; padding: 8px; }
        input[type="checkbox"] { width: auto; margin-left: 10px; }
        button { padding: 10px 20px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        button:hover { background-color: #45a049; }
        #server-list { margin-top: 20px; }
    </style>
</head>
<body>
    <h1>Amnezia-UI for ASUSWRT-Merlin (v0.2.2)</h1>
    <h2>Add/Generate VPN Config</h2>
    <form id="config-form">
        <div class="form-group">
            <label for="iface">Interface Name:</label>
            <input type="text" id="iface" name="iface" placeholder="e.g., amnezia0" required>
        </div>
        <div class="form-group">
            <label for="private-key">Private Key:</label>
            <input type="text" id="private-key" name="private-key" placeholder="Private key" required>
        </div>
        <div class="form-group">
            <label for="public-key">Public Key:</label>
            <input type="text" id="public-key" name="public-key" placeholder="Server public key" required>
        </div>
        <div class="form-group">
            <label for="endpoint">Endpoint:</label>
            <input type="text" id="endpoint" name="endpoint" placeholder="e.g., server_ip:51820" required>
        </div>
        <div class="form-group">
            <label for="allowed-ips">Allowed IPs:</label>
            <input type="text" id="allowed-ips" name="allowed-ips" placeholder="e.g., 0.0.0.0/0" required>
        </div>
        <div class="form-group">
            <label for="psk">Preshared Key (optional):</label>
            <input type="text" id="psk" name="psk" placeholder="Preshared key">
        </div>
        <div class="form-group">
            <label for="s1">S1 Key (AmneziaWG Obfuscation, optional):</label>
            <input type="text" id="s1" name="s1" placeholder="32-byte S1 key">
        </div>
        <div class="form-group">
            <label for="s2">S2 Key (AmneziaWG Obfuscation, optional):</label>
            <input type="text" id="s2" name="s2" placeholder="32-byte S2 key">
        </div>
        <div class="form-group">
            <label for="s3">S3 Key (AmneziaWG Obfuscation, optional):</label>
            <input type="text" id="s3" name="s3" placeholder="32-byte S3 key">
        </div>
        <div class="form-group">
            <label for="s4">S4 Key (AmneziaWG Obfuscation, optional):</label>
            <input type="text" id="s4" name="s4" placeholder="32-byte S4 key">
        </div>
        <div class="form-group">
            <label for="h1-h4">H1-H4 Range (optional):</label>
            <select id="h1-h4" name="h1-h4">
                <option value="">None</option>
                <option value="1">H1</option>
                <option value="2">H2</option>
                <option value="3">H3</option>
                <option value="4">H4</option>
            </select>
        </div>
        <div class="form-group">
            <label for="rules">Selective Routing Rules (comma-separated IP/domains, optional):</label>
            <input type="text" id="rules" name="rules" placeholder="e.g., 8.8.8.8,example.com,192.168.1.0/24">
        </div>
        <div class="form-group">
            <label for="obfs">Enable Obfuscation:</label>
            <input type="checkbox" id="obfs" name="obfs">
        </div>
        <button type="button" onclick="generateConfig()">Add Config</button>
    </form>

    <h2>Server List</h2>
    <div id="server-list"></div>

    <script>
        function generateConfig() {
            const formData = new FormData();
            formData.append("action", "generate");
            formData.append("iface", document.getElementById("iface").value);
            formData.append("private-key", document.getElementById("private-key").value);
            formData.append("public-key", document.getElementById("public-key").value);
            formData.append("endpoint", document.getElementById("endpoint").value);
            formData.append("allowed-ips", document.getElementById("allowed-ips").value);
            formData.append("psk", document.getElementById("psk").value);
            formData.append("obfs", document.getElementById("obfs").checked ? "on" : "off");
            formData.append("s1", document.getElementById("s1").value);
            formData.append("s2", document.getElementById("s2").value);
            formData.append("s3", document.getElementById("s3").value);
            formData.append("s4", document.getElementById("s4").value);
            formData.append("h1-h4", document.getElementById("h1-h4").value);
            formData.append("rules", document.getElementById("rules").value);

            // Basic validation
            if (!formData.get("iface") || !formData.get("private-key") || !formData.get("public-key") || !formData.get("endpoint") || !formData.get("allowed-ips")) {
                alert("Please fill all required fields");
                return;
            }
            if (formData.get("s1") && !/^[A-Za-z0-9+/=]{44}$/.test(formData.get("s1"))) {
                alert("S1 must be a 32-byte base64 key");
                return;
            }
            if (formData.get("s2") && !/^[A-Za-z0-9+/=]{44}$/.test(formData.get("s2"))) {
                alert("S2 must be a 32-byte base64 key");
                return;
            }
            if (formData.get("s3") && !/^[A-Za-z0-9+/=]{44}$/.test(formData.get("s3"))) {
                alert("S3 must be a 32-byte base64 key");
                return;
            }
            if (formData.get("s4") && !/^[A-Za-z0-9+/=]{44}$/.test(formData.get("s4"))) {
                alert("S4 must be a 32-byte base64 key");
                return;
            }
            if (formData.get("h1-h4") && !["1", "2", "3", "4"].includes(formData.get("h1-h4"))) {
                alert("H1-H4 must be between 1 and 4");
                return;
            }

            fetch("/jffs/scripts/amnezia-ui", {
                method: "POST",
                body: formData
            })
            .then(response => response.text())
            .then(data => {
                alert(data);
                listServers();
            })
            .catch(error => alert("Error: " + error));
        }

        function listServers() {
            fetch("/jffs/scripts/amnezia-ui?action=list")
                .then(response => response.json())
                .then(data => {
                    const serverList = document.getElementById("server-list");
                    serverList.innerHTML = "";
                    data.forEach(server => {
                        const div = document.createElement("div");
                        div.innerHTML = `Interface: ${server.iface}, Endpoint: ${server.endpoint}, Status: ${server.status}
                            <button onclick="startServer('${server.iface}')">Start</button>
                            <button onclick="stopServer('${server.iface}')">Stop</button>
                            <button onclick="deleteServer('${server.iface}')">Delete</button>`;
                        serverList.appendChild(div);
                    });
                })
                .catch(error => alert("Error listing servers: " + error));
        }

        function startServer(iface) {
            fetch(`/jffs/scripts/amnezia-ui?action=start&iface=${iface}`)
                .then(response => response.text())
                .then(data => {
                    alert(data);
                    listServers();
                })
                .catch(error => alert("Error: " + error));
        }

        function stopServer(iface) {
            fetch(`/jffs/scripts/amnezia-ui?action=stop
