#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Roc target dir name for this machine (extend as needed)
uname_s="$(uname -s)"
uname_m="$(uname -m)"
case "${uname_s}-${uname_m}" in
  Linux-x86_64)   ROC_TARGET="x64musl" ;;  # template uses musl on Linux; use x64gnu if you link glibc
  Linux-aarch64)  ROC_TARGET="arm64musl" ;;
  Darwin-x86_64)  ROC_TARGET="x64mac" ;;
  Darwin-arm64)   ROC_TARGET="arm64mac" ;;
  *)
    echo "unsupported native: ${uname_s}-${uname_m}" >&2
    exit 1
    ;;
esac

echo "BUILD host (release staticlib) → ${ROC_TARGET}"

cargo build --release --locked --lib -p roc-bevy-host

# Cargo emits target/release/libhost.a when [lib] name = "host"
SRC="target/release/libhost.a"
if [[ ! -f "$SRC" ]]; then
  # workspace may put it under host/target
  SRC="host/target/release/libhost.a"
fi
if [[ ! -f "$SRC" ]]; then
  echo "missing libhost.a (looked in target/release and host/target/release)" >&2
  exit 1
fi

DEST_DIR="platform/targets/${ROC_TARGET}"
mkdir -p "$DEST_DIR"
cp -f "$SRC" "${DEST_DIR}/libhost.a"
sha256sum "${DEST_DIR}/libhost.a" | awk '{print $1}' > "${DEST_DIR}/libhost.a.sha256"

echo "HOST ${DEST_DIR}/libhost.a"
ls -la "${DEST_DIR}/libhost.a"
