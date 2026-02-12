# OctoPrint Remote Setup

> Run OctoPrint inside Docker on a remote machine, controlled by an AI agent over WhatsApp. Monitor and manage your 3D printer from anywhere.

![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)

## Overview

This project sets up a complete remote 3D printing workflow:

1. **OctoPrint** runs inside a Docker container on a remote machine (Kali Linux laptop in a garage)
2. **OpenClaw AI agent** (G1) connects to the machine via Tailscale VPN
3. **WhatsApp** is the control interface: send commands, receive status updates
4. **Webcam feed** (planned) for live print monitoring

```
[Phone/WhatsApp] --> [OpenClaw Gateway] --> [Kali Node (Docker)]
                                                |
                                          [OctoPrint :5000]
                                                |
                                          [Ender 3 V2 USB]
                                          [Webcam USB]
```

## Hardware

| Component | Details |
|---|---|
| **Print Server** | Lenovo laptop, Intel i3-3120M, 12GB RAM, 428GB disk |
| **OS** | Kali Linux (Docker host) |
| **Printer** | Creality Ender 3 V2 (220x220x250mm) |
| **Connection** | USB to printer, USB webcam (planned) |
| **Network** | Tailscale VPN mesh network |

## Setup Guide

### 1. Install Docker on the host machine

```bash
sudo apt update && sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

### 2. Install Tailscale for remote access

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### 3. Run OpenClaw node in Docker

```bash
docker run -d \
  --name openclaw-node \
  --restart unless-stopped \
  --device=/dev/ttyUSB0:/dev/ttyUSB0 \
  --device=/dev/video0:/dev/video0 \
  -p 5000:5000 \
  openclaw/node
```

### 4. Install OctoPrint inside the container

```bash
# Enter the container
docker exec -it openclaw-node bash

# Install OctoPrint and dependencies
pip install octoprint zipstream-ng pydantic pydantic-settings

# Start OctoPrint
nohup python3 -m octoprint serve --host 0.0.0.0 --port 5000 &
```

### 5. Access OctoPrint

- **Local:** `http://localhost:5000`
- **Remote (Tailscale):** `http://<tailscale-ip>:5000`
- **Via AI agent:** Send commands through WhatsApp

## Docker Device Passthrough

For USB printer and webcam access, the container needs device access:

```bash
# Find your devices on the host
ls /dev/ttyUSB*    # Printer (usually ttyUSB0)
ls /dev/video*     # Webcam (usually video0)

# Pass them to Docker
docker run -d \
  --device=/dev/ttyUSB0:/dev/ttyUSB0 \
  --device=/dev/video0:/dev/video0 \
  ...
```

## Scripts

### `scripts/install_octoprint.sh`
Automated OctoPrint installation inside Docker with all dependencies.

### `scripts/health_check.py`
Checks OctoPrint status, printer connection, and webcam feed.

### `scripts/setup_webcam.sh`
Configures mjpg-streamer for webcam streaming to OctoPrint.

## AI Agent Integration

The G1 agent can:
- **Upload G-code** to OctoPrint via API
- **Start/pause/cancel** prints remotely
- **Monitor** temperatures and progress
- **Alert** on failures via WhatsApp
- **Generate G-code** from 3D models on the fly

Example interaction:
```
You:  "Print the calibration cube"
G1:   Generating 20mm cube... Slicing for Ender 3 V2...
      Uploading to OctoPrint... Print started!
      Estimated time: 45 minutes
      I'll send you updates every 15 min.
```

## Network Architecture

```
Phone (anywhere)
  |
  v
WhatsApp --> OpenClaw Gateway (cloud)
                |
                v (Tailscale VPN)
          Kali Laptop (garage)
            |-- Docker: OpenClaw Node
            |     |-- OctoPrint (:5000)
            |     |-- mjpg-streamer (:8080)
            |-- USB: Ender 3 V2
            |-- USB: Webcam
```

## Troubleshooting

### OctoPrint won't start
```bash
# Check for missing modules
python3 -c "import octoprint; print('OK')"

# Common missing deps
pip install zipstream-ng pydantic pydantic-settings
```

### Printer not detected
```bash
# Check USB on HOST (not container)
ls -la /dev/ttyUSB*

# Restart container with device
docker stop openclaw-node
docker run --device=/dev/ttyUSB0 ...
```

### Webcam not working
```bash
# Check on HOST
ls /dev/video*
v4l2-ctl --list-devices

# Pass to container
docker run --device=/dev/video0 ...
```

## Status

- [x] OctoPrint installed and running in Docker
- [x] Remote access via Tailscale VPN
- [x] AI agent (G1) connected and controlling
- [x] G-code generation and upload pipeline
- [ ] Webcam live feed (needs USB passthrough)
- [ ] Automated print monitoring and alerts
- [ ] Timelapse recording

## License

MIT License. See [LICENSE](LICENSE).

## Author

**Khaled Elmajed** ([@2233morpheus](https://github.com/2233morpheus))
