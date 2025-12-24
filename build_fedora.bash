#!/usr/bin/env bash

SB_SRCDIR="./source/"
SB_BUILDDIR="./servo/"
SB_CONTAINER="servobuild-fedora"
UNAME="servobuild"

if [[ -z "$SB_WORKDIR"	]];then
	SB_WORKDIR="$(dirname $(readlink -f $0))"
fi

if [[ -z "$SB_WORKDIR" ]]; then
	echo "ERROR: \$WORKDIR not set"
	exit -1
fi

if [[ ! -z "$SB_DEBUG" ]]; then
	SB_MACH_BUILD="-d"
else
	SB_MACH_BUILD="-r"
fi

(
	cd "$SB_WORKDIR"
	mkdir -p "$SB_BUILDDIR"
	if [[ ! -d "$SB_SRCDIR" ]] || [[ ! "$(ls -A $SB_SRCDIR)" ]]; then
		git clone --depth=1 "https://github.com/servo/servo.git" "$SB_SRCDIR"
	fi
	docker build --build-arg SERVOBUILD_UID="$(id -u)" --build-arg SERVOBUILD_GID="$(id -g)" --build-arg UNAME="$UNAME" -t "$SB_CONTAINER" -f fedora.dockerfile .
	docker run --rm -e SB_MACH_BUILD="$SB_MACH_BUILD" -v "$SB_SRCDIR":"/home/$UNAME/servo:Z" "$SB_CONTAINER"
	cp -r "${SB_SRCDIR}/resources" "$SB_BUILDDIR"
	if [[ ! -z "$SB_DEBUG" ]]; then
		cp "${SB_SRCDIR}/target/debug/servo" "$SB_BUILDDIR"
	else
		cp "${SB_SRCDIR}/target/release/servo" "$SB_BUILDDIR"
	fi
) || exit -1
