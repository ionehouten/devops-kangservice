FROM alpine:3.21

RUN apk add --no-cache curl bash tar redis

ENV REDIS_EXPORTER_VERSION=1.51.0

RUN curl -LO https://github.com/oliver006/redis_exporter/releases/download/v${REDIS_EXPORTER_VERSION}/redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz && \
    tar -xzf redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz && \
    mv redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64/redis_exporter /usr/local/bin/ && \
    rm -rf redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64*

COPY redis-discover.sh /redis-discover.sh
RUN chmod +x /redis-discover.sh

ENTRYPOINT ["/usr/bin/env", "bash", "/redis-discover.sh"]
