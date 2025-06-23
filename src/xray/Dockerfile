FROM alpine:latest

WORKDIR /root

COPY xray.sh /root/xray.sh
COPY config.json /etc/xray/config.json

RUN set -ex \
	&& apk add --no-cache ca-certificates \
	&& mkdir -p /var/log/xray /usr/share/xray \
	&& chmod +x /root/xray.sh \
	&& /root/xray.sh \
	&& rm -fv /root/xray.sh

CMD ["/usr/bin/xray", "-config", "/etc/xray/config.json"]
