#!/usr/bin/env bash
# F-21 companion — install the `mdv` shim to /usr/local/bin/mdv.
# Uses sudo since /usr/local/bin is root-owned on stock macOS.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/scripts/mdv"
DEST="/usr/local/bin/mdv"

if [[ ! -f "$SRC" ]]; then
  echo "ERROR: $SRC not found" >&2
  exit 1
fi

echo "==> installing $SRC to $DEST"
echo "    (sudo prompt expected — /usr/local/bin is root-owned)"
sudo install -m 0755 "$SRC" "$DEST"

echo "==> verifying"
if command -v mdv >/dev/null 2>&1; then
  echo "OK: $(command -v mdv)"
  echo "Try:  mdv some-file.md"
else
  echo "WARN: installed to $DEST but not on PATH. Check your shell's PATH." >&2
fi
