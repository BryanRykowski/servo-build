#!/usr/bin/env sh
. "/home/$UNAME/.cargo/env"
. "/home/$UNAME/.local/bin/env"
cd servo
./mach build "$SB_MACH_BUILD"
