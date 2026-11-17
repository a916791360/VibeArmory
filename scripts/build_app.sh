#!/bin/bash
set -e

echo "🚀 Building VibeArmory Universal Release (Apple Silicon + Intel)..."
cd "$(dirname "$0")/.."

# 1. Swift release build for both arm64 and x86_64
swift build -c release --arch arm64 --arch x86_64

# 2. Prepare .app bundle structure
APP_DIR="dist/VibeArmory.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 3. Copy binary, plist, and assets
if [ -f ".build/apple/Products/Release/VibeArmory" ]; then
    cp .build/apple/Products/Release/VibeArmory "$MACOS_DIR/VibeArmory"
else
    cp .build/release/VibeArmory "$MACOS_DIR/VibeArmory"
fi
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

# 5. Create distribution zip preserving macOS metadata, permissions, and signatures
ZIP_NAME="dist/VibeArmory-v0.1.5-macOS-Universal.zip"
rm -f "$ZIP_NAME"
echo "📦 Packaging distribution archive: $ZIP_NAME..."
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_NAME"

echo "✅ Build complete! App located at: $(pwd)/$APP_DIR"
echo "📦 Distribution zip located at: $(pwd)/$ZIP_NAME"
echo "👉 You can run it with: open '$APP_DIR'"
