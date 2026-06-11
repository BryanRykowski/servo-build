#!/usr/bin/env bash

sb_srcdir="./source/"
sb_builddir="./servo/"
sb_container="servobuild-fedora"
sb_user="servobuild"

while [[ "$#" -gt 0 ]]; do
	if [[ "$1" == "--skip-app-build" ]]; then
		sb_skip_app=1
	elif [[ "$1" == "--rebuild-image" ]]; then
		sb_rebuild_image=1
	elif [[ "$1" == "--debug" ]]; then
		sb_debug=1
	elif [[ "$1" == "--clean-image" ]]; then
		sb_clean_image=1
	elif [[ "$1" == "--clean-all" ]]; then
		sb_clean_image=1
		sb_clean_dir=1
	elif [[ "$1" == "--version" ]]; then
		if [[ -z "$2" ]]; then
			printf "[ERROR] --version needs a value\n"
			exit -1
		fi
		shift
		sb_version="$1"
	else
		printf "[ERROR] unrecognized arg $1\n"
		exit -1
	fi
	shift
done

if [[ -z "$sb_workdir"	]];then
	sb_workdir="$(dirname $(readlink -f $0))"
fi

if [[ -z "$sb_workdir" ]]; then
	echo "ERROR: \$sb_workdir not set"
	exit -1
fi

if [[ -n "$sb_debug" ]]; then
	sb_mach_build="--debug"
else
	sb_mach_build="--release"
fi

if [[ -z "$sb_version" ]]; then
	sb_version="latest"
fi

if [[ -n "$sb_clean_image" ]]; then
	docker image rm "$sb_container:$sb_version"
fi

if [[ -n "$sb_clean_dir" ]]; then
	(
		cd "$sb_workdir" || exit -1
		rm -r "$sb_builddir" || exit -1
		rm -rf "$sb_srcdir" || exit -1
	) || exit -1
fi

if [[ -n "$sb_clean_image" || -n "$sb_clean_dir" ]]; then
	exit 0
fi

(
	cd "$sb_workdir" || exit -1
	mkdir -p "$sb_builddir"
	if [[ ! -d "$sb_srcdir" ]] || [[ ! "$(ls -A $sb_srcdir)" ]]; then
		git clone --depth=1 "https://github.com/servo/servo.git" "$sb_srcdir"
	fi
	
	if [[ -n "$sb_rebuild_image" && -n "$(docker images -q servobuild-fedora:$sb_version 2> /dev/null)" ]]; then
		docker image rm "$sb_container:$sb_version"
	fi

	if [[ -z "$(docker images -q servobuild-fedora:$sb_version 2> /dev/null)" ]]; then
		docker build --build-arg SERVOBUILD_UID="$(id -u)" --build-arg SERVOBUILD_GID="$(id -g)" --build-arg SB_USER="$sb_user" --build-arg sb_version="$sb_version" -t "$sb_container:$sb_version" -f fedora.dockerfile .
	else
		printf "skipping docker image build\n"
	fi

	if [[ -z "$sb_skip_app" ]]; then
		docker run --rm -e SB_MACH_BUILD="$sb_mach_build" -v "$sb_srcdir":"/home/$sb_user/servo:Z" "$sb_container:$sb_version"
	fi

	cp -r "${sb_srcdir}/resources" "$sb_builddir"
	if [[ ! -z "$SB_DEBUG" ]]; then
		cp "${sb_srcdir}/target/debug/servoshell" "$sb_builddir"
	else
		cp "${sb_srcdir}/target/release/servoshell" "$sb_builddir"
	fi
) || exit -1
