FROM caddy:builder-alpine AS builder

RUN set -eu && \
    xcaddy build \
    --with github.com/ggicci/caddy-jwt

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
