FROM linuxserver/radarr

COPY radarr/40-symlink-logs /etc/cont-init.d/
COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY healthcheck-web arr-go-import.sh /etc/sbin/
COPY radarr/auto-manual-import.sh /etc/services.d/auto-manual-import/run

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    HEALTHCHECK_PORT=7878

RUN apk add --no-cache curl
HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount && /etc/sbin/healthcheck-web
