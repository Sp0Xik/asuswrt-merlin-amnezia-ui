// Amnezia-UI Script (adapted from XRAYUI)
const SCRIPT_PATH = '/jffs/scripts/amnezia-ui';

function updateStatus() {
    fetch(SCRIPT_PATH + '?action=status')
        .then(response => response.text())
        .then(data => {
            document.getElementById('status-text').textContent = data;
        })
        .catch(err => console.error('Status fetch error:', err));
}

function startAmnezia() {
    fetch(SCRIPT_PATH + '?action=start', { method: 'POST' })
        .then(() => updateStatus())
        .catch(err => alert('Start error: ' + err));
}

function stopAmnezia() {
    fetch(SCRIPT_PATH + '?action=stop', { method: 'POST' })
        .then(() => updateStatus())
        .catch(err => alert('Stop error: ' + err));
}

function generateConfig() {
    const formData = new FormData(document.getElementById('server-form'));
    formData.append('action', 'generate');
    fetch(SCRIPT_PATH, { method: 'POST', body: formData })
        .then(response => response.text())
        .then(data => {
            alert('Config generated: ' + data);
            loadServers();
        })
        .catch(err => alert('Generate error: ' + err));
}

function addServer() {
    const formData = new FormData(document.getElementById('server-form'));
    formData.append('action', 'add');
    fetch(SCRIPT_PATH, { method: 'POST', body: formData })
        .then(() => {
            loadServers();
            document.getElementById('server-form').reset();
        })
        .catch(err => alert('Add error: ' + err));
}

function loadServers() {
    fetch(SCRIPT_PATH + '?action=list')
        .then(response => response.json())
        .then(servers => {
            const tbody = document.querySelector('#servers-table tbody');
            tbody.innerHTML = '';
            servers.forEach(server => {
                const row = tbody.insertRow();
                row.insertCell(0).textContent = server.iface;
                row.insertCell(1).textContent = server.endpoint;
                row.insertCell(2).textContent = server.status;
                const actions = row.insertCell(3);
                const delBtn = document.createElement('button');
                delBtn.textContent = 'Delete';
                delBtn.className = 'delete';
                delBtn.onclick = () => deleteServer(server.iface);
                actions.appendChild(delBtn);
            });
        })
        .catch(err => console.error('Load servers error:', err));
}

function deleteServer(iface) {
    fetch(SCRIPT_PATH + '?action=delete&iface=' + encodeURIComponent(iface), { method: 'POST' })
        .then(() => loadServers())
        .catch(err => alert('Delete error: ' + err));
}

// Init
document.addEventListener('DOMContentLoaded', () => {
    updateStatus();
    loadServers();
    document.getElementById('server-form').addEventListener('submit', (e) => {
        e.preventDefault();
        addServer();
    });
    setInterval(updateStatus, 5000);  // Poll every 5s
});
