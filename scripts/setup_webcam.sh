#!/bin/bash
# mjpg-streamer setup for OctoPrint webcam
# Run inside Docker container after device passthrough

set -e

if [ ! -e /dev/video0 ]; then
    echo "ERROR: /dev/video0 not found"
    echo "Start container with: --device=/dev/video0:/dev/video0"
    exit 1
fi

echo "=== Installing mjpg-streamer ==="
apt-get update && apt-get install -y cmake libjpeg-dev gcc g++ git

cd /tmp
git clone https://github.com/jacksonliam/mjpg-streamer.git
cd mjpg-streamer/mjpg-streamer-experimental
make
make install

echo "=== Starting webcam stream ==="
mjpg_streamer -i "input_uvc.so -d /dev/video0 -r 1280x720 -f 15" \
              -o "output_http.so -p 8080 -w /usr/local/share/mjpg-streamer/www" &

echo "Webcam streaming at http://localhost:8080/?action=stream"
echo "Snapshot URL: http://localhost:8080/?action=snapshot"
