FROM fedora:latest
RUN dnf install -y curl git make automake gcc gcc-c++ libtool gcc-c++ libXi-devel freetype-devel libunwind-devel mesa-libGL-devel mesa-libEGL-devel glib2-devel libX11-devel libXrandr-devel gperf fontconfig-devel cabextract ttmkfdir expat-devel rpm-build cmake libXcursor-devel libXmu-devel dbus-devel ncurses-devel harfbuzz-devel ccache clang clang-libs llvm python3-devel gstreamer1-devel gstreamer1-plugins-base-devel gstreamer1-plugins-good gstreamer1-plugins-bad-free-devel gstreamer1-plugins-ugly-free libjpeg-turbo-devel zlib-ng libjpeg-turbo vulkan-loader libxkbcommon libxkbcommon-x11 wireshark-cli 
ARG UNAME=servobuild
ENV UNAME=$UNAME
ARG SERVOBUILD_UID=1000
ARG SERVOBUILD_GID=1000
RUN <<EOF
groupadd -g "$SERVOBUILD_GID" -o "$UNAME"
useradd -m -u "$SERVOBUILD_UID" -g "$SERVOBUILD_GID" -o "$UNAME"
curl -LsSf https://astral.sh/uv/install.sh | sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh || exit -1
chmod +x rustup.sh
./rustup.sh -y
EOF
ADD fedora_commands.sh commands.sh
ENTRYPOINT ["sh", "commands.sh"]
