FROM hotio/nzbhydra2

COPY healthcheck-mount /etc/cont-init.d/00-check-mount

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

HEALTHCHECK --start-period=10s CMD /etc/cont-init.d/00-healthcheck-mount
