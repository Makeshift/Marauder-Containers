# Shamelessly adapted from mumiehub/rclone-mount
FROM alpine:latest

# Using the very latest commit as we're using the bleeding-edge new union
# TODO: Pin this when a new version comes out
ENV RCLONE_VERSION="master"

ENV GOPATH="/go" \
    MountPoint="/shared/merged" \
    RemotePath="union:" \
    UnmountCommands="-u -z" \
    CacheFolderSuffix="" \
    ItemsPerUpload=100 \
    CacheSizePerMountGb=10

RUN apk --no-cache upgrade

RUN apk --no-cache add --virtual .s6-build-deps curl && \
    curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz" && \
    tar xfz /tmp/s6-overlay.tar.gz -C / && \
    apk --no-cache del .s6-build-deps

RUN apk --no-cache add --virtual .rclone-build-deps go git alpine-sdk && \
    apk --no-cache add --virtual .rclone-run-deps ca-certificates fuse fuse-dev && \
    go get -u -v github.com/rclone/rclone@${RCLONE_VERSION} && \
    cp /go/bin/rclone /usr/sbin/ && \
    apk del .rclone-build-deps && \
    rm -rf /usr/lib/go /go /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

RUN apk --no-cache add --virtual .run-deps findutils moreutils bash gettext && \
    mkdir -p /config/rclone

COPY rootfs/ /

RUN chmod +x /usr/sbin/*

ENTRYPOINT ["/init"]
