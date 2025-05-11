FROM caddy:builder-alpine AS builder

RUN set -eu && \
    xcaddy build \
    --with github.com/greenpau/caddy-security

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
