FROM alpine as builder

RUN apk update && apk add binutils ca-certificates && rm -rf /var/cache/apk/*

COPY ./build /build
COPY detect.sh /

RUN /detect.sh

FROM scratch 

COPY --from=builder /external-dns /bin/external-dns
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Run as UID for nobody since k8s pod securityContext runAsNonRoot can't resolve the user ID:
# https://github.com/kubernetes/kubernetes/issues/40958
USER 65534

ENTRYPOINT ["/bin/external-dns"]
