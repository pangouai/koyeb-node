#!/bin/sh
set -eu

sed -e "s|__UUID__|${NODE_UUID}|g" \
    -e "s|__PATH__|${NODE_PATH}|g" \
    /opt/xray/config.tpl.json > /opt/xray/config.json

# 把 nginx.conf 里的占位符替换成真实的 location 块
cat > /tmp/node-location.conf <<EOF
        location = ${NODE_PATH} {
            proxy_pass http://127.0.0.1:10000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$connection_upgrade;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
            proxy_buffering off;
        }
EOF

# 用 awk 做多行替换（sed 不适合）
awk '
  /__NODE_LOCATION__/ {
    while ((getline line < "/tmp/node-location.conf") > 0) print line
    close("/tmp/node-location.conf")
    next
  }
  { print }
' /etc/nginx/nginx.conf.tpl > /etc/nginx/nginx.conf

echo "[entrypoint] uuid=${NODE_UUID} path=${NODE_PATH}"
echo "---- generated nginx.conf (node part) ----"
cat /tmp/node-location.conf
