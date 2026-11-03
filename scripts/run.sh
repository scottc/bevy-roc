#!/usr/bin/env bash
set -e
XKB=`pkg-config --variable=libdir xkbcommon 2>/dev/null`
WL=`pkg-config --variable=libdir wayland-client 2>/dev/null`
export LD_LIBRARY_PATH="/run/opengl-driver/lib:$XKB:$WL:$LD_LIBRARY_PATH"
cd host
exec cargo run "$@"
