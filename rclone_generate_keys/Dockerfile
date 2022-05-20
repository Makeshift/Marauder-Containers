FROM golang:alpine AS build

ENV GOPATH="/go"
WORKDIR /app
COPY rclone_generate_keys/* ./
RUN apk add --no-cache alpine-sdk && \
    go install && \
    go build .

FROM alpine

COPY --from=build /app/marauder_rclone_generate_keys ./obscure
COPY rclone_generate_keys/run.sh .

ENTRYPOINT ["/run.sh"]
