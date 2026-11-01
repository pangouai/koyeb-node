# 合并镜像：OpenList（伪装站）+ Xray（VLESS-WS 节点）
#
# Koyeb 免费层只有 1 个 service，且不支持原始 TCP 端口，
# 但 HTTP 端口原生支持 WebSocket —— 所以用 VLESS-WS。
#
#   https://<app>.koyeb.app/         → OpenList（伪装站 / 网盘）
#   https://<app>.koyeb.app/<PATH>   → Xray VLESS-WS 节点
#
# 敏感配置（UUID / PATH / 数据库密码）全部从环境变量注入。

FROM alpine:3.20

ARG OPENLIST_VER=v4.2.9
ARG XRAY_VER=v26.10.31

RUN apk add --no-cache \
      curl unzip tzdata ca-certificates supervisor nginx bash libstdc++

# ---------- OpenList（tar 里只有一个 openlist 文件）----------
RUN mkdir -p /opt/openlist/data \
 && curl -fsSL -o /tmp/ol.tar.gz \
      "https://github.com/OpenListTeam/OpenList/releases/download/${OPENLIST_VER}/openlist-linux-musl-amd64-lite.tar.gz" \
 && tar -xzf /tmp/ol.tar.gz -C /opt/openlist \
 && rm -f /tmp/ol.tar.gz \
 && chmod +x /opt/openlist/openlist

# ---------- Xray ----------
RUN mkdir -p /opt/xray \
 && curl -fsSL -o /tmp/xray.zip \
      "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
 && unzip -q /tmp/xray.zip -d /opt/xray \
 && rm -f /tmp/xray.zip \
 && chmod +x /opt/xray/xray

# ---------- 用户与目录 ----------
RUN addgroup -g 1001 openlist \
 && adduser -D -u 1001 -G openlist openlist \
 && mkdir -p /tmp/temp /tmp/bleve \
 && chown -R openlist:openlist /opt/openlist /tmp/temp /tmp/bleve

# ---------- 配置 ----------
COPY xray.tpl.json     /opt/xray/config.tpl.json
COPY nginx.conf        /etc/nginx/nginx.conf
COPY entrypoint.sh     /entrypoint-relay.sh
COPY supervisord.conf  /etc/supervisord.conf
RUN chmod +x /entrypoint-relay.sh

ENV TZ=Asia/Shanghai \
    UMASK=022 \
    DB_PORT=5432 \
    DB_NAME=postgres \
    DB_PREFIX=x_ \
    DB_SSLMODE=require

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
