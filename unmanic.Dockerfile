FROM josh5/unmanic

COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY healthcheck-web /etc/sbin/

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    HEALTHCHECK_PORT=8888

HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount && /etc/sbin/healthcheck-web