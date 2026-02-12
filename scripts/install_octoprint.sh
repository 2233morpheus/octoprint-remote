#!/bin/bash
# OctoPrint installer for Docker containers
# Run inside the container: bash scripts/install_octoprint.sh

set -e
echo "=== Installing OctoPrint ==="

pip install --user octoprint
pip install --user zipstream-ng pydantic pydantic-settings

echo "=== Verifying installation ==="
python3 -c "import octoprint; print(f'OctoPrint {octoprint.__version__} installed')"

echo "=== Creating config directory ==="
mkdir -p ~/.octoprint

echo "=== Done! Start with: ==="
echo "python3 -m octoprint serve --host 0.0.0.0 --port 5000"
