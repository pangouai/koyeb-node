#!/bin/sh
set -eu

sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/xray/config.tpl.json > /opt/xray/config.json

cat > /tmp/node-path.conf <<EOF
map \$uri \$is_node {
    default 0;
    ${NODE_PATH} 1;
}
EOF

echo "[entrypoint] uuid=${NODE_UUID} path=${NODE_PATH}"
cat /tmp/node-path.conf
