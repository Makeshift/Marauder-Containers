FROM eafxx/traktarr


COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY traktarr/change_timeout.sh /etc/cont-init.d/01-change-timeout

RUN apk add --no-cache sed findutils
