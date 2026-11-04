#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Must be the Blueprint-exposed binary (roc-stable on PATH in dev/shell/tasks).
ROC_BIN="$(command -v roc-stable || command -v roc || true)"
if [ -z "$ROC_BIN" ]; then
  echo "error: roc-stable not on PATH; use Blueprint dev env (nix run … -- shell / run …)" >&2
  exit 1
fi

CACHE_DIR="${ROC_GLUE_CACHE:-$ROOT/.cache/glue}"
mkdir -p "$CACHE_DIR"

VERSION_LINE="$("$ROC_BIN" version 2>/dev/null || "$ROC_BIN" --version 2>/dev/null || true)"
COMMIT="$(printf '%s\n' "$VERSION_LINE" | sed -n 's/.*nightly-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-\([0-9a-f]\{7,40\}\).*/\1/p')"

if [ -z "$COMMIT" ]; then
  echo "error: could not parse nightly commit from: $VERSION_LINE" >&2
  exit 1
fi

RUST_GLUE="$CACHE_DIR/$COMMIT/RustGlue.roc"
if [ ! -f "$RUST_GLUE" ]; then
  mkdir -p "$(dirname "$RUST_GLUE")"
  URL="https://raw.githubusercontent.com/roc-lang/roc/${COMMIT}/src/glue/src/RustGlue.roc"
  echo "fetch: $URL"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "$RUST_GLUE"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$RUST_GLUE" "$URL"
  else
    echo "error: need curl or wget" >&2
    exit 1
  fi
else
  echo "cache: $RUST_GLUE"
fi

OUT_DIR="$ROOT/host/src/glue_out"
mkdir -p "$OUT_DIR"

echo "glue: $RUST_GLUE → $OUT_DIR  (roc: $ROC_BIN)"
"$ROC_BIN" glue "$RUST_GLUE" "$OUT_DIR" "$ROOT/platform/main.roc"

ls -la "$OUT_DIR"
echo "ok"
