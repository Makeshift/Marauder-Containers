# Shamelessly adapted from mumiehub/rclone-mount
FROM alpine:latest

ENV GOPATH="/go" \
    MountPoint="/shared/merged" \
    RemotePath="union:" \
    UnmountCommands="-u -z" \
    ItemsPerUpload=100 \
    MaxGbPerUpload=25 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN apk --no-cache upgrade

RUN apk --no-cache add --virtual .s6-build-deps curl && \
    curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz" && \
    tar xfz /tmp/s6-overlay.tar.gz -C / && \
    apk --no-cache del .s6-build-deps

RUN apk --no-cache add --virtual .rclone-build-deps unzip && \
    apk --no-cache add --virtual .rclone-run-deps ca-certificates fuse fuse-dev && \
    apk --no-cache add --virtual .run-deps findutils moreutils coreutils bash gettext cdrkit grep gawk curl jq && \
    curl https://rclone.org/install.sh | bash && \
    apk del .rclone-build-deps && \
    rm -rf /usr/lib/go /go /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rclone/rootfs/ /
COPY healthcheck-mount /usr/sbin/

HEALTHCHECK --start-period=10s CMD /usr/sbin/healthcheck-mount

ENTRYPOINT ["/init"]
