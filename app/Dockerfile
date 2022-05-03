FROM golang:1.18.1-alpine AS builder

WORKDIR /go/squash/
COPY . .

RUN go install squash

FROM golang:1.18.1-alpine

COPY --from=builder /go/bin/squash /

STOPSIGNAL SIGTERM
EXPOSE 8080
ENTRYPOINT ["/squash"]