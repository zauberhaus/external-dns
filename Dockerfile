FROM golang:1.15-alpine as builder

RUN apk add --no-cache git make bash

COPY version.txt /version.txt

RUN VERSION=$(cat /version.txt) && \
    cd && git clone https://github.com/kubernetes-sigs/external-dns.git \
    && cd external-dns \
    && if [ "$VERSION" != "main" ] ; then git checkout tags/${VERSION} -b ${VERSION} ; fi


WORKDIR /root/external-dns

RUN go mod download

RUN CGO_ENABLED=0 go build -o build/external-dns -v -ldflags "-X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=$(git describe --tags --always --dirty) -w -s" .

FROM alpine
COPY --from=builder /root/external-dns/build/external-dns /bin/external-dns   
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Run as UID for nobody since k8s pod securityContext runAsNonRoot can't resolve the user ID:
# https://github.com/kubernetes/kubernetes/issues/40958
USER 65534

ENTRYPOINT ["/bin/external-dns"]
