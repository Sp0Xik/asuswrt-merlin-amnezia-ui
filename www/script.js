document.getElementById('config-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = {
        action: 'add',
        iface: formData.get('iface'),
        'private-key': formData.get('private-key'),
        'public-key': formData.get('public-key'),
        endpoint: formData.get('endpoint'),
        'allowed-ips': formData.get('allowed-ips'),
        psk: formData.get('psk'),
        obfs: formData.get('obfs') ? 'on' : '',
        s1: formData.get('s1'),
        s2: formData.get('s2'),
        s3: formData.get('s3'),
        s4: formData.get('s4'),
        'h1-h4': formData.get('h1-h4'),
        rules: formData.get('rules')
    };

    // Basic validation
    if (!data.iface || !data['private-key'] || !data['public-key'] || !data.endpoint) {
        alert('Please fill all required fields');
        return;
    }
    if (data.s1 && !/^[A-Za-z0-9+/=]{44}$/.test(data.s1)) {
        alert('S1 must be a 32-byte base64 key');
        return;
    }
    if (data.s2 && !/^[A-Za-z0-9+/=]{44}$/.test(data.s2)) {
        alert('S2 must be a 32-byte base64 key');
        return;
    }
    if (data.s3 && !/^[A-Za-z0-9+/=]{44}$/.test(data.s3)) {
        alert('S3 must be a 32-byte base64 key');
        return;
    }
    if (data.s4 && !/^[A-Za-z0-9+/=]{44}$/.test(data.s4)) {
        alert('S4 must be a 32-byte base64 key');
        return;
    }
    if (data['h1-h4'] && !['1','2','3','4'].includes(data['h1-h4'])) {
        alert('H1-H4 must be between 1 and 4');
        return;
    }

    try {
        const response = await fetch('/jffs/scripts/amnezia-ui', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(data)
        });
        const text = await response.text();
        alert(text);
        loadServers();
    } catch (error) {
        alert('Error: ' + error.message);
    }
});

async function loadServers() {
    const response = await fetch('/jffs/scripts/amnezia-ui?action=list');
    const servers = await response.json();
    const table = document.getElementById('servers');
    table.innerHTML = '<tr><th>Interface</th><th>Endpoint</th><th>Status</th><th>Actions</th></tr>';
    servers.forEach(server => {
        const row = table.insertRow();
        row.innerHTML = `
            <td>${server.iface}</td>
            <td>${server.endpoint}</td>
            <td>${server.status}</td>
            <td>
                <button onclick="startServer('${server.iface}')">Start</button>
                <button onclick="stopServer('${server.iface}')">Stop</button>
                <button onclick="deleteServer('${server.iface}')">Delete</button>
            </td>
        `;
    });
}

async function startServer(iface) {
    const response = await fetch(`/jffs/scripts/amnezia-ui?action=start&iface=${iface}`, { method: 'POST' });
    alert(await response.text());
    loadServers();
}

async function stopServer(iface) {
    const response = await fetch(`/jffs/scripts/amnezia-ui?action=stop&iface=${iface}`, { method: 'POST' });
    alert(await response.text());
    loadServers();
}

async function deleteServer(iface) {
    const response = await fetch(`/jffs/scripts/amnezia-ui?action=delete&iface=${iface}`, { method: 'POST' });
    alert(await response.text());
    loadServers();
}

async function loadLogs() {
    const response = await fetch('/tmp/amnezia-ui-install.log');
    document.getElementById('logs').textContent = await response.text();
}

loadServers();
loadLogs();
setInterval(loadLogs, 5000);
