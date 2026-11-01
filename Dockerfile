# 合并镜像：OpenList（伪装站）+ Xray（VLESS-WS 节点）
#
# Koyeb 免费层只有 1 个 service，且不支持原始 TCP 端口，
# 但 HTTP 端口原生支持 WebSocket —— 所以用 VLESS-WS。
#
#   https://<app>.koyeb.app/         → OpenList（伪装站 / 网盘）
#   https://<app>.koyeb.app/<PATH>   → Xray VLESS-WS 节点
#
# 关键收益：出口 IP 是 Koyeb 自己的，不是 Cloudflare，
#          因此 CF→CF 自环问题消失。
#
# 进程编排（supervisord）：
#   openlist :5244   xray :10000   nginx :8080（对外）
#   nginx 按 $uri 把流量分给 openlist 或 xray

FROM openlistteam/openlist:latest

USER root

ARG XRAY_VER=v26.10.31

RUN apk add --no-cache curl unzip supervisor tzdata ca-certificates nginx \
 && mkdir -p /opt/xray \
 && curl -fsSL -o /tmp/xray.zip \
      "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
 && unzip -q /tmp/xray.zip -d /opt/xray \
 && rm -f /tmp/xray.zip \
 && chmod +x /opt/xray/xray \
 && /opt/xray/xray version

COPY xray.tpl.json     /opt/xray/config.tpl.json
COPY nginx.conf        /etc/nginx/nginx.conf
COPY entrypoint.sh     /entrypoint-relay.sh
COPY supervisord.conf  /etc/supervisord.conf
RUN chmod +x /entrypoint-relay.sh

ENV TZ=Asia/Shanghai \
    UMASK=022 \
    NODE_UUID=2a7108f4-b462-4d6d-a5f5-d611aef9c35a \
    NODE_PATH=/fe82f69e

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
