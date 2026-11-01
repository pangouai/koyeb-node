# 最小可验证镜像：只装 Xray，跑 VLESS-WS
# 目的：先确认 Koyeb 构建链路正常，再逐步加 OpenList。
#
# 启动后：
#   https://<app>.koyeb.app/<NODE_PATH> → VLESS-WS
#   其他路径 → 一个静态占位页

FROM alpine:3.20

ARG XRAY_VER=v26.10.31

RUN apk add --no-cache curl unzip tzdata ca-certificates supervisor

RUN mkdir -p /opt/xray \
 && curl -fsSL -o /tmp/xray.zip \
      "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
 && unzip -q /tmp/xray.zip -d /opt/xray \
 && rm -f /tmp/xray.zip \
 && chmod +x /opt/xray/xray

COPY xray.tpl.json     /opt/xray/config.tpl.json
COPY entrypoint.sh     /entrypoint.sh
COPY supervisord.conf  /etc/supervisord.conf
COPY site/index.html   /app/site/index.html
RUN chmod +x /entrypoint.sh

ENV TZ=Asia/Shanghai \
    NODE_UUID=2a7108f4-b462-4d6d-a5f5-d611aef9c35a \
    NODE_PATH=/fe82f69e

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
