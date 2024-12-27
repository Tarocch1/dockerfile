FROM alpine:latest

RUN set -eu && \
    apk --no-cache add \
    tini \
    wsdd && \
    rm -rf /tmp/* /var/cache/apk/*

ENTRYPOINT ["/sbin/tini", "--", "wsdd"]
