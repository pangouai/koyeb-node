#!/bin/sh
set -eu

sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/xray/config.tpl.json > /opt/xray/config.json

# $upstream: 节点路径 → Xray 地址；其余 → "static"（走文件）
cat > /tmp/node-path.conf <<EOF
map \$uri \$upstream {
    default "static";
    ${NODE_PATH} "http://127.0.0.1:10000";
}
EOF

echo "[entrypoint] uuid=${NODE_UUID} path=${NODE_PATH}"
cat /tmp/node-path.conf
