FROM golang:1.15-alpine as builder

ARG VERSION=v0.7.4

RUN apk add --no-cache git make bash

RUN cd && git clone https://github.com/kubernetes-sigs/external-dns.git \
    && cd external-dns \
    && git checkout tags/${VERSION} -b ${VERSION}

WORKDIR /root/external-dns

RUN CGO_ENABLED=0 go build -o build/external-dns -v -ldflags "-X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=$(git describe --tags --always --dirty) -w -s" .

FROM alpine
COPY --from=builder /root/external-dns/build/external-dns /usr/local/bin    