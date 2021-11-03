FROM linuxserver/transmission

COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
