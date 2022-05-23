FROM linuxserver/bazarr

COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY healthcheck-web /etc/sbin/

RUN apk add --no-cache curl

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    HEALTHCHECK_PORT=6767

HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount && /etc/sbin/healthcheck-web
