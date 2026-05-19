#!/usr/bin/env bash
# Build MarkdownViewer.app from `swift build` output.
# No Xcode required — uses CommandLineTools + manual bundle layout.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="MarkdownViewer"
BUNDLE_ID="com.laoban.MarkdownViewer"
VERSION="0.2.0-dev"
BUILD_DIR="$ROOT/build"
APP_DIR="$BUILD_DIR/${APP_NAME}.app"
ICON_SRC="$ROOT/assets/AppIcon.icns"

echo "==> regenerating AppIcon.icns"
"$ROOT/scripts/make-icon.swift" "$ICON_SRC"

echo "==> swift build (release, arm64)"
swift build -c release --arch arm64

BIN_DIR="$ROOT/.build/release"
BIN="$BIN_DIR/$APP_NAME"
RES_BUNDLE="$BIN_DIR/${APP_NAME}_${APP_NAME}.bundle"

if [[ ! -f "$BIN" ]]; then
  echo "ERROR: built binary not found at $BIN" >&2
  exit 1
fi
if [[ ! -d "$RES_BUNDLE" ]]; then
  echo "ERROR: resource bundle not found at $RES_BUNDLE" >&2
  exit 1
fi

echo "==> assembling $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Binary
cp "$BIN" "$APP_DIR/Contents/MacOS/$APP_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"

# Resource bundle — keep its exact name so Bundle.module resolves at runtime.
cp -R "$RES_BUNDLE" "$APP_DIR/Contents/Resources/"

# App icon — must sit at Contents/Resources/AppIcon.icns (referenced by Info.plist).
if [[ ! -f "$ICON_SRC" ]]; then
  echo "ERROR: AppIcon.icns not found at $ICON_SRC (make-icon.swift should have produced it)" >&2
  exit 1
fi
cp "$ICON_SRC" "$APP_DIR/Contents/Resources/AppIcon.icns"

# Third-party license attributions (MIT + BSD-3) — required by markdown-it and highlight.js.
cp "$ROOT/THIRD_PARTY_LICENSES.md" "$APP_DIR/Contents/Resources/THIRD_PARTY_LICENSES.md"

# Info.plist
cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key><string>Markdown Viewer</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleExecutable</key><string>${APP_NAME}</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleSignature</key><string>????</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundleVersion</key><string>${VERSION}</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
  <key>NSSupportsAutomaticTermination</key><true/>
  <key>NSSupportsSuddenTermination</key><true/>
  <key>CFBundleDocumentTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeName</key><string>Markdown Document</string>
      <key>CFBundleTypeRole</key><string>Viewer</string>
      <key>LSHandlerRank</key><string>Alternate</string>
      <key>LSItemContentTypes</key>
      <array>
        <string>net.daringfireball.markdown</string>
      </array>
    </dict>
  </array>
  <key>UTImportedTypeDeclarations</key>
  <array>
    <dict>
      <key>UTTypeIdentifier</key><string>net.daringfireball.markdown</string>
      <key>UTTypeDescription</key><string>Markdown Document</string>
      <key>UTTypeConformsTo</key>
      <array>
        <string>public.plain-text</string>
      </array>
      <key>UTTypeTagSpecification</key>
      <dict>
        <key>public.filename-extension</key>
        <array>
          <string>md</string>
          <string>markdown</string>
          <string>mdown</string>
          <string>mkd</string>
          <string>mkdn</string>
          <string>mdtxt</string>
        </array>
        <key>public.mime-type</key>
        <array>
          <string>text/markdown</string>
        </array>
      </dict>
    </dict>
  </array>
</dict>
</plist>
PLIST

# Touch the app bundle so LaunchServices picks up the new Info.plist.
touch "$APP_DIR"

echo "==> built: $APP_DIR"
du -sh "$APP_DIR"
