#!/bin/sh
set -eu

# ── 渲染 OpenList 配置 ──────────────────────────────
# 所有敏感值都从环境变量注入，不写死在镜像里
cat > /tmp/config.json <<EOF
{
  "force": false,
  "jwt_secret": "${OL_JWT_SECRET:-random_generated}",
  "database": {
    "type": "postgres",
    "host": "${DB_HOST}",
    "port": ${DB_PORT:-5432},
    "user": "${DB_USER}",
    "password": "${DB_PASS}",
    "name": "${DB_NAME:-postgres}",
    "db_file": "",
    "table_prefix": "${DB_PREFIX:-x_}",
    "ssl_mode": "${DB_SSLMODE:-require}",
    "dsn": ""
  },
  "scheme": {
    "address": "127.0.0.1",
    "http_port": 5244
  },
  "temp_dir": "/tmp/temp",
  "bleve_dir": "/tmp/bleve",
  "log": { "enable": false }
}
EOF
chmod 644 /tmp/config.json
echo "[entrypoint] openlist config written (db=${DB_HOST}/${DB_NAME:-postgres})"

# ── 渲染 Xray 配置 ──────────────────────────────────
sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/xray/config.tpl.json > /opt/xray/config.json
echo "[entrypoint] xray: uuid=${NODE_UUID} path=${NODE_PATH}"

# ── 生成 nginx 分流规则 ─────────────────────────────
cat > /tmp/node-path.conf <<EOF
map \$uri \$backend {
    default openlist_backend;
    ${NODE_PATH} xray_backend;
}
EOF
echo "[entrypoint] nginx map ready"
