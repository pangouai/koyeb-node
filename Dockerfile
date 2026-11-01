# 合并镜像：OpenList (HTTP 5244) + relay (TCP 8443)
#
# Koyeb 免费层只有 1 个 service，必须合并才能同时提供：
#   - HTTP 5244 → OpenList（伪装站 / 网盘）
#   - TCP  8443 → relay（落地转发）
#
# 官方镜像：openlistteam/openlist:latest
#   二进制在 /opt/openlist/openlist
#   基础镜像 alpine，默认用户 openlist(1001)
#   CMD 是 /entrypoint.sh（会自己起 openlist server）
#
# 我们用 supervisord 同时管两个进程，所以覆盖 CMD。

FROM openlistteam/openlist:latest

USER root

# relay 需要 node；supervisord 需要 python
RUN apk add --no-cache nodejs supervisor tzdata curl

WORKDIR /app
COPY relay.js /app/relay.js
COPY supervisord.conf /etc/supervisord.conf

# OpenList 的数据目录要可写（supervisord 以 root 起，openlist 进程降权到 openlist 用户）
RUN mkdir -p /opt/openlist/data /tmp/temp /tmp/bleve \
 && chown -R openlist:openlist /opt/openlist/data /tmp/temp /tmp/bleve 2>/dev/null || true

ENV TZ=Asia/Shanghai \
    UMASK=022 \
    PORT=8443 \
    HTTP_PORT=0

EXPOSE 5244 8443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
