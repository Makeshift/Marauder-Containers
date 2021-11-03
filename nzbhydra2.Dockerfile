FROM hotio/nzbhydra2

COPY healthcheck-mount /etc/cont-init.d/00-check-mount
