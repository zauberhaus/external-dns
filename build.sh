#/bin/sh

VERSION=`cat version.txt`
REPO=https://github.com/kubernetes-sigs/external-dns.git
ARCHS="arm64 armv6 armv7 s390x ppc64le amd64 386"

git clone ${REPO} src 
cd src 
echo "Checkout tag $VERSION" 
if [ "$VERSION" != "main" ] && [ ! -z "$VERSION" ] ; then git checkout tags/${VERSION} -b ${VERSION} ; fi

mkdir -p ../build

VERSION=$(git describe --tags --always --dirty) 
#echo "Build version $VERSION" 
FLAGS="-X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=$VERSION -w -s"
export CGO_ENABLED=0
export GOOS=linux

for arch in $ARCHS ; do
    if expr "$arch" : "armv6$" 1>/dev/null; then
        export GOARCH=arm 
        export GOARM=6
    elif expr "$arch" : "armv7$" 1>/dev/null; then
        export GOARCH=arm
        export GOARM=7
    else 
        export GOARCH=$arch
    fi

    echo "Build external-dns.$arch $VERSION" 
    go build -o ../build/external-dns.$arch -ldflags "$FLAGS"
done
