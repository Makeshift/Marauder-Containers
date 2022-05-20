FROM linuxserver/sabnzbd

COPY healthcheck-web /etc/sbin/

ENV HEALTHCHECK_PORT=8080

RUN apk add --no-cache curl
HEALTHCHECK --start-period=10s CMD /etc/sbin/healthcheck-web
