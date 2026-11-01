#!/bin/sh
set -eu

# 渲染 Xray 配置
sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/xray/config.tpl.json > /opt/xray/config.json

# 生成 nginx map：节点路径 → xray_backend，其余 → openlist_backend
cat > /tmp/node-path.conf <<EOF
map \$uri \$backend {
    default openlist_backend;
    ${NODE_PATH} xray_backend;
}
EOF

echo "[entrypoint] ready"
echo "  uuid = ${NODE_UUID}"
echo "  path = ${NODE_PATH}"
echo "  ---- node-path.conf ----"
cat /tmp/node-path.conf
