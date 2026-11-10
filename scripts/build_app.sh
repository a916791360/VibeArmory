#!/bin/bash
set -e

echo "🚀 Building VibeArmory Release..."
cd "$(dirname "$0")/.."

# 1. Swift release build
swift build -c release

# 2. Prepare .app bundle structure
APP_DIR="dist/VibeArmory.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 3. Copy binary, plist, and assets
cp .build/release/VibeArmory "$MACOS_DIR/VibeArmory"
chmod +x "$MACOS_DIR/VibeArmory"

cp Sources/VibeArmory/App/Info.plist "$CONTENTS_DIR/Info.plist"

if [ -f "Sources/VibeArmory/Resources/AppIcon.icns" ]; then
    cp Sources/VibeArmory/Resources/AppIcon.icns "$RESOURCES_DIR/AppIcon.icns"
fi

if [ -f "Sources/VibeArmory/Resources/AppLogo.png" ]; then
    cp Sources/VibeArmory/Resources/AppLogo.png "$RESOURCES_DIR/AppLogo.png"
fi

# 4. Ad-hoc codesign
if command -v codesign &> /dev/null; then
    echo "✍️  Ad-hoc codesigning VibeArmory.app..."
    codesign -s - --force --deep "$APP_DIR"
fi

echo "✅ Build complete! App located at: $(pwd)/$APP_DIR"
echo "👉 You can run it with: open '$APP_DIR'"
