#!/bin/sh

A1=$(readelf -h /sbin/apk | grep "Machine:" | awk -F: '{ print $2}' | xargs) 
A2=$(readelf -A /sbin/apk | grep "Tag_CPU_arch:" | awk -F: '{ print $2}' | xargs)  
ARCH="$A1$A2"

echo "Search: >$ARCH<"

case "$A1$A2" in
	*X86-64*)
		ARCH="amd64"
		;;
	*80386*)
		ARCH="386"
		;;
	"PowerPC64")
		ARCH="ppc64le"
		;;
	"IBM S/390")
		ARCH="s390x"
		;;
    AArch64*)
		ARCH="arm64"
		;;
	ARMv7*)
		ARCH="armv7"
		;;
	ARMv6*)
		ARCH="armv6"
		;;
	*)
		echo "Sorry, unknown architecture"
        exit 1
		;;
esac

echo "Arch: $ARCH"
cp /build/external-dns.$ARCH /external-dns