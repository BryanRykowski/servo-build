ARG sb_version=latest
FROM fedora:$sb_version
ARG SB_USER=servobuild
ENV SB_USER=$SB_USER
ARG SERVOBUILD_UID=1000
ARG SERVOBUILD_GID=1000
RUN <<EOF
cat > /commands.sh << 'IEOF'
#!/usr/bin/env sh
. "/home/$SB_USER/.cargo/env"
. "/home/$SB_USER/.local/bin/env"
cd servo
./mach build "$SB_MACH_BUILD"
IEOF
dnf install -y curl git make automake gcc gcc-c++ libtool gcc-c++ libXi-devel freetype-devel libunwind-devel mesa-libGL-devel mesa-libEGL-devel glib2-devel libX11-devel libXrandr-devel gperf fontconfig-devel cabextract ttmkfdir expat-devel rpm-build cmake libXcursor-devel libXmu-devel dbus-devel ncurses-devel harfbuzz-devel ccache clang clang-libs llvm python3-devel gstreamer1-devel gstreamer1-plugins-base-devel gstreamer1-plugins-good gstreamer1-plugins-bad-free-devel gstreamer1-plugins-ugly-free libjpeg-turbo-devel zlib-ng libjpeg-turbo vulkan-loader libxkbcommon libxkbcommon-x11 wireshark-cli 
groupadd -g "$SERVOBUILD_GID" -o "$SB_USER"
useradd -m -u "$SERVOBUILD_UID" -g "$SERVOBUILD_GID" -o "$SB_USER" --shell /usr/bin/sh
EOF
USER $SB_USER
WORKDIR /home/$SB_USER
RUN <<EOF
curl -LsSf https://astral.sh/uv/install.sh | sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh || exit -1
chmod +x rustup.sh
./rustup.sh -y
EOF
ENTRYPOINT ["sh", "/commands.sh"]
