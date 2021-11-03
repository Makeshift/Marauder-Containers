FROM linuxserver/bazarr

COPY bazarr/change_timeout.sh /etc/cont-init.d/10-change-timeout
COPY healthcheck-mount.sh /etc/cont-init.d/00-healthcheck-mount

RUN apk add --no-cache sed findutils
