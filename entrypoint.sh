#!/bin/sh
set -eu

sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/xray/config.tpl.json > /opt/xray/config.json

echo "[entrypoint] uuid=${NODE_UUID} path=${NODE_PATH}"
cat /opt/xray/config.json
