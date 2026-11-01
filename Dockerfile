# Koyeb 单 service：伪装站 + VLESS-WS 节点
#
#   https://<app>.koyeb.app/         → 静态伪装页
#   https://<app>.koyeb.app/<PATH>   → Xray VLESS-WS
#
# 编排：supervisord → render / xray / nginx
#   render: 生成 xray 配置 + nginx 的 location 块
#   xray  :10000（内部）
#   nginx :8080（对外，Koyeb 网关指向这里）

FROM alpine:3.20

ARG XRAY_VER=v26.10.31

RUN apk add --no-cache \
      curl unzip tzdata ca-certificates supervisor nginx

RUN mkdir -p /opt/xray \
 && curl -fsSL -o /tmp/xray.zip \
      "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
 && unzip -q /tmp/xray.zip -d /opt/xray \
 && rm -f /tmp/xray.zip \
 && chmod +x /opt/xray/xray

COPY xray.tpl.json       /opt/xray/config.tpl.json
COPY nginx.conf          /etc/nginx/nginx.conf.tpl
COPY entrypoint.sh       /entrypoint.sh
COPY supervisord.conf    /etc/supervisord.conf
COPY site/index.html     /app/site/index.html
RUN chmod +x /entrypoint.sh

ENV TZ=Asia/Shanghai \
    NODE_UUID=2a7108f4-b462-4d6d-a5f5-d611aef9c35a \
    NODE_PATH=/fe82f69e

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
