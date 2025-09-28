# Web Interface Directory

This directory contains the web interface files for Amnezia-UI.

## Contents

The web interface provides a browser-based management interface for AmneziaWG connections.

### Files (automatically created during runtime)

- `index.html` - Main web interface page (created by amnezia-ui script)
- Static assets and templates as needed

### Access

The web interface is accessible at `http://router-ip:8080` when started with:

```bash
amnezia-ui web start
```

### Features

- Start/stop VPN interfaces
- View connection status
- Configuration management
- Real-time monitoring

### Technical Details

- Uses busybox httpd server
- Lightweight HTML/CSS/JavaScript interface
- RESTful API for management operations
- Responsive design for mobile devices
