FROM alpine:latest

RUN set -eu && \
    apk --no-cache add \
    tini \
    bash \
    tzdata \
    shadow \
    samba && \
    addgroup -S smb && \
    rm -f /etc/samba/smb.conf && \
    rm -rf /tmp/* /var/cache/apk/*

COPY --chmod=755 samba.sh /usr/bin/samba.sh
COPY --chmod=644 smb.conf /etc/samba/smb.default

VOLUME /storage
EXPOSE 445

ENV NAME="Data"
ENV USER="samba"
ENV PASS="secret"
ENV UID=1000
ENV GID=1000
ENV RW=true

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/samba.sh"]
