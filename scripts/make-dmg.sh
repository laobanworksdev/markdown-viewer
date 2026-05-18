#!/usr/bin/env bash
# Wrap MarkdownViewer.app into an unsigned DMG with drag-to-Applications layout.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="MarkdownViewer"
VOL_NAME="Markdown Viewer"
VERSION="0.1.0"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/${APP_NAME}.app"
DMG="$BUILD_DIR/${APP_NAME}-${VERSION}.dmg"
STAGE="$BUILD_DIR/.dmg-stage"

if [[ ! -d "$APP" ]]; then
  echo "ERROR: $APP not found — run scripts/build.sh first." >&2
  exit 1
fi

echo "==> staging DMG contents"
rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

echo "==> hdiutil create $DMG"
hdiutil create \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$DMG" >/dev/null

rm -rf "$STAGE"

echo "==> built: $DMG"
du -sh "$DMG"
