FROM caddy:builder-alpine AS builder

RUN set -eu && \
    xcaddy build \
    --with github.com/greenpau/caddy-security \
    --with github.com/lindenlab/caddy-s3-proxy

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
