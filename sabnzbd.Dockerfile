FROM linuxserver/sabnzbd

COPY healthcheck-mount /etc/cont-init.d/00-healthcheck-mount
