FROM josh5/unmanic:0.1.3

COPY unmanic/tail-logs /etc/services.d/tail-logs/run
COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
COPY healthcheck-web /etc/sbin/
# Patch that makes the postprocessor move instead of copy
COPY unmanic/postprocessor.py /usr/local/lib/python3.8/dist-packages/unmanic/libs/postprocessor.py

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    HEALTHCHECK_PORT=8888

HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount && /etc/sbin/healthcheck-web
