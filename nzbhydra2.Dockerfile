FROM hotio/nzbhydra2

COPY healthcheck-web /etc/sbin/

ENV HEALTHCHECK_PORT=5076

RUN apt-get update && apt-get install curl && rm -rf /var/lib/apt/lists/*
HEALTHCHECK --start-period=10s CMD /etc/sbin/healthcheck-web
