#!/bin/sh
set -e


mkdir -p /tmp/env

# Write the value once at startup
echo "{\"carconnectivity_ui_url\":\"$CARCONNECTIVITY_UI_URL\"}" > /tmp/env/env.json
echo '/:grafana:$1$U5gCZFMC$uGuUBI/zN7or6IfG4em921' >> /tmp/httpd.conf

# Start tiny HTTP server in background
httpd -p 127.0.0.1:8081 -h /tmp/env -c /tmp/httpd.conf

# Start Grafana (original entrypoint)
exec /run.sh
