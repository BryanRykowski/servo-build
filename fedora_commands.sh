#!/usr/bin/env sh
su - "$UNAME"
. /root/.local/bin/env
. /root/.cargo/env
cd servo
./mach build "$SB_MACH_BUILD"
