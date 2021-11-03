FROM eafxx/traktarr


COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY traktarr/change_timeout.sh /etc/cont-init.d/01-change-timeout

RUN apk add --no-cache sed findutils

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount
