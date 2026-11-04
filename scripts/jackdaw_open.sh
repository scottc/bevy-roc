#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
HOST_DIR="${JACKDAW_HOST_DIR:-$ROOT/host}"
BIN_DIR="$HOST_DIR/.bin"
LINK="$BIN_DIR/roc-stable"

ROC="$(command -v roc-stable || command -v roc || true)"
if [[ -z "$ROC" ]]; then
  echo "error: roc-stable not on PATH (use Blueprint dev / this script via jackdaw-open task)" >&2
  exit 1
fi

mkdir -p "$BIN_DIR"
rm -f "$LINK"

# Follow symlinks to the real file.
REAL="$(readlink -f "$ROC" 2>/dev/null || true)"

# Ephemeral Blueprint env — do not link into .blueprint/run/...
if [[ -n "$REAL" && -x "$REAL" && "$REAL" != *"/.blueprint/run/"* ]]; then
  ln -sfn "$REAL" "$LINK"
  echo "roc-stable → $LINK -> $REAL  (stable symlink)"
else
  # Copy the binary (follow one level of symlinks). Survives run-* teardown.
  cp -L "$ROC" "$LINK"
  chmod +x "$LINK"
  echo "roc-stable → $LINK  (copied from $ROC; run env is ephemeral)"
fi

# Sanity check: must be executable now, not a dead symlink
if [[ ! -x "$LINK" ]]; then
  echo "error: $LINK is not executable" >&2
  ls -la "$BIN_DIR" >&2
  exit 1
fi
"$LINK" version >/dev/null || "$LINK" --version >/dev/null || {
  echo "error: $LINK does not run (wrapper may need its original install tree)" >&2
  exit 1
}

export PATH="$BIN_DIR:$PATH"
export ROC="$LINK"

XKB="$(pkg-config --variable=libdir xkbcommon 2>/dev/null || true)"
WL="$(pkg-config --variable=libdir wayland-client 2>/dev/null || true)"
export LD_LIBRARY_PATH="/run/opengl-driver/lib${XKB:+:$XKB}${WL:+:$WL}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd "$ROOT"
exec jd open "$HOST_DIR"
