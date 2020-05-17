FROM golang:alpine AS build

ENV GOPATH="/go"
WORKDIR /app
COPY main.go .
RUN go mod init obscure && \
    go build .

FROM alpine

COPY --from=build /app/obscure .
COPY run.sh .

ENTRYPOINT ["/run.sh"]
