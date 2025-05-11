FROM caddy:builder-alpine AS builder

RUN set -eu && \
    xcaddy build \
    --with github.com/sagikazarmark/caddy-fs-s3

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
