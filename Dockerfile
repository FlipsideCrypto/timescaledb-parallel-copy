# build stage
FROM golang:latest as builder
ENV GO111MODULE=on
WORKDIR /timescaledb-parallel-copy

COPY ./ .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ./bin/timescaledb-parallel-copy ./cmd/timescaledb-parallel-copy/main.go

# final stage
FROM alpine:3.8 as alpine
RUN apk --no-cache add ca-certificates tzdata zip bash
WORKDIR /usr/share/zoneinfo
RUN zip -r -0 /zoneinfo.zip .
ENV ZONEINFO /zoneinfo.zip
WORKDIR /
COPY --from=builder /timescaledb-parallel-copy/bin/timescaledb-parallel-copy /usr/bin/timescaledb-parallel-copy

ENTRYPOINT [ "timescaledb-parallel-copy" ]