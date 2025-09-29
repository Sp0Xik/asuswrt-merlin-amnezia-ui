<%nvram("productid");%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Amnezia-UI Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #0b1220;
            color: #e6edf3;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            background: #161b22;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid #30363d;
        }
        .status-panel {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        .panel {
            background: #0d1117;
            border: 1px solid #30363d;
            border-radius: 8px;
            padding: 20px;
        }
        .panel h3 {
            margin-top: 0;
            color: #58a6ff;
        }
        .btn {
            display: inline-block;
            padding: 10px 16px;
            margin: 5px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        .btn-primary {
            background: #238636;
            color: white;
        }
        .btn-secondary {
            background: #0969da;
            color: white;
        }
        .btn-danger {
            background: #da3633;
            color: white;
        }
        .btn:hover {
            opacity: 0.8;
        }
        .status {
            padding: 8px 12px;
            border-radius: 4px;
            font-weight: bold;
        }
        .status.active {
            background: #238636;
            color: white;
        }
        .status.inactive {
            background: #da3633;
            color: white;
        }
        .log-output {
            background: #010409;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            height: 300px;
            overflow-y: auto;
            white-space: pre-wrap;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #30363d;
            border-radius: 6px;
            background: #0d1117;
            color: #e6edf3;
        }
        .config-upload {
            border: 2px dashed #30363d;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
        }
        .config-upload:hover {
            border-color: #58a6ff;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Amnezia-UI Management Panel</h1>
            <p>AmneziaWG (WireGuard with DPI bypass) management interface</p>
        </div>
        
        <div class="status-panel">
            <div class="panel">
                <h3>Service Status</h3>
                <div id="service-status">
                    <span class="status" id="web-status">Checking...</span>
                    <p>Web UI: <span id="web-port">8080</span></p>
                    <button class="btn btn-primary" onclick="startWebUI()">Start Web UI</button>
                    <button class="btn btn-danger" onclick="stopWebUI()">Stop Web UI</button>
                </div>
            </div>
            
            <div class="panel">
                <h3>VPN Connections</h3>
                <div id="vpn-status">
                    <div id="interface-list">Loading...</div>
                    <button class="btn btn-secondary" onclick="refreshStatus()">Refresh</button>
                </div>
            </div>
            
            <div class="panel">
                <h3>Quick Actions</h3>
                <a href="http://<%nvram("lan_ipaddr");%>:8080/" class="btn btn-primary" target="_blank">Open Full Web UI</a>
                <button class="btn btn-secondary" onclick="viewLogs()">View Logs</button>
                <button class="btn btn-secondary" onclick="downloadConfig()">Export Config</button>
            </div>
        </div>
        
        <div class="panel">
            <h3>Configuration Management</h3>
            <div class="config-upload" onclick="document.getElementById('config-file').click()">
                <p>📁 Click to upload AmneziaWG configuration file</p>
                <input type="file" id="config-file" accept=".conf" style="display: none" onchange="uploadConfig(this)">
            </div>
            
            <div class="form-group" style="margin-top: 20px">
                <label for="interface-name">Interface Name:</label>
                <input type="text" id="interface-name" class="form-control" value="amnezia0" placeholder="amnezia0">
            </div>
            
            <button class="btn btn-primary" onclick="startInterface()">Start Interface</button>
            <button class="btn btn-danger" onclick="stopInterface()">Stop Interface</button>
        </div>
        
        <div class="panel" id="log-panel" style="display: none">
            <h3>System Logs</h3>
            <div class="log-output" id="log-output">Loading logs...</div>
            <button class="btn btn-secondary" onclick="clearLogs()">Clear Logs</button>
        </div>
    </div>
    
    <script>
        function checkStatus() {
            // Check web UI status
            fetch('/cgi-bin/amnezia-ui?action=web-status')
                .then(response => response.text())
                .then(data => {
                    const statusEl = document.getElementById('web-status');
                    if (data.includes('running')) {
                        statusEl.className = 'status active';
                        statusEl.textContent = 'Running';
                    } else {
                        statusEl.className = 'status inactive';
                        statusEl.textContent = 'Stopped';
                    }
                })
                .catch(() => {
                    document.getElementById('web-status').textContent = 'Unknown';
                });
            
            // Check interface status
            fetch('/cgi-bin/amnezia-ui?action=status')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('interface-list').innerHTML = 
                        data.split('\n').map(line => 
                            line.trim() ? `<div>${line}</div>` : ''
                        ).join('');
                })
                .catch(() => {
                    document.getElementById('interface-list').innerHTML = 'Error loading interfaces';
                });
        }
        
        function startWebUI() {
            fetch('/cgi-bin/amnezia-ui?action=web-start', {method: 'POST'})
                .then(() => setTimeout(checkStatus, 2000));
        }
        
        function stopWebUI() {
            fetch('/cgi-bin/amnezia-ui?action=web-stop', {method: 'POST'})
                .then(() => setTimeout(checkStatus, 2000));
        }
        
        function refreshStatus() {
            checkStatus();
        }
        
        function startInterface() {
            const name = document.getElementById('interface-name').value || 'amnezia0';
            fetch(`/cgi-bin/amnezia-ui?action=start&interface=${name}`, {method: 'POST'})
                .then(() => setTimeout(checkStatus, 2000));
        }
        
        function stopInterface() {
            const name = document.getElementById('interface-name').value || 'amnezia0';
            fetch(`/cgi-bin/amnezia-ui?action=stop&interface=${name}`, {method: 'POST'})
                .then(() => setTimeout(checkStatus, 2000));
        }
        
        function uploadConfig(input) {
            if (input.files && input.files[0]) {
                const file = input.files[0];
                const formData = new FormData();
                formData.append('config', file);
                
                fetch('/cgi-bin/amnezia-ui?action=upload-config', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.text())
                .then(data => {
                    alert('Configuration uploaded: ' + data);
                    checkStatus();
                })
                .catch(err => alert('Upload failed: ' + err));
            }
        }
        
        function viewLogs() {
            const panel = document.getElementById('log-panel');
            if (panel.style.display === 'none') {
                panel.style.display = 'block';
                fetch('/cgi-bin/amnezia-ui?action=logs')
                    .then(response => response.text())
                    .then(data => {
                        document.getElementById('log-output').textContent = data;
                    });
            } else {
                panel.style.display = 'none';
            }
        }
        
        function clearLogs() {
            fetch('/cgi-bin/amnezia-ui?action=clear-logs', {method: 'POST'})
                .then(() => {
                    document.getElementById('log-output').textContent = 'Logs cleared';
                });
        }
        
        function downloadConfig() {
            const name = document.getElementById('interface-name').value || 'amnezia0';
            window.open(`/cgi-bin/amnezia-ui?action=download-config&interface=${name}`);
        }
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            checkStatus();
            setInterval(checkStatus, 10000); // Refresh every 10 seconds
        });
    </script>
</body>
</html>
