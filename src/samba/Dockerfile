FROM alpine:latest

RUN set -eu && \
    apk --no-cache add \
    tini \
    bash \
    tzdata \
    samba \
    rm -rf /tmp/* /var/cache/apk/*

COPY --chmod=755 samba.sh /usr/bin/samba.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/samba.sh"]
