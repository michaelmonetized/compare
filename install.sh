#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PREFIX="${PREFIX:-/usr/local}"
DEST="$PREFIX/bin/compare"

mkdir -p "$PREFIX/bin"
install -m 755 "$ROOT/bin/compare" "$DEST"

echo "Installed compare to $DEST"