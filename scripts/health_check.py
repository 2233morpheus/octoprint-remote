#!/usr/bin/env python3
"""OctoPrint health checker. Run periodically to verify system status."""

import urllib.request
import json
import sys

OCTOPRINT_URL = "http://localhost:5000"

def check_octoprint():
    try:
        req = urllib.request.urlopen(f"{OCTOPRINT_URL}/api/version", timeout=5)
        data = json.loads(req.read())
        print(f"OctoPrint: {data.get('server', 'unknown')} (API {data.get('api', '?')})")
        return True
    except Exception as e:
        print(f"OctoPrint: DOWN ({e})")
        return False

def check_printer():
    try:
        req = urllib.request.urlopen(f"{OCTOPRINT_URL}/api/connection", timeout=5)
        data = json.loads(req.read())
        state = data.get("current", {}).get("state", "unknown")
        print(f"Printer: {state}")
        return "closed" not in state.lower()
    except Exception as e:
        print(f"Printer: UNKNOWN ({e})")
        return False

def check_webcam():
    try:
        req = urllib.request.urlopen("http://localhost:8080/?action=snapshot", timeout=5)
        size = len(req.read())
        print(f"Webcam: OK ({size} bytes)")
        return True
    except Exception as e:
        print(f"Webcam: DOWN ({e})")
        return False

if __name__ == "__main__":
    results = {
        "octoprint": check_octoprint(),
        "printer": check_printer(),
        "webcam": check_webcam(),
    }
    healthy = all(results.values())
    print(f"\nOverall: {'HEALTHY' if healthy else 'DEGRADED'}")
    sys.exit(0 if healthy else 1)
