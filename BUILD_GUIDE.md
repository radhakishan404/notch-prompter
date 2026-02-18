# Notch Prompter - Build & Run Guide

A free, open-source teleprompter for Mac.

---

## Quick Start - Run from Terminal

### Option 1: Run the Built App Directly
```bash
# Navigate to the project directory
cd /path/to/notch-prompter

# Build and run in one command
xcodebuild -project NotchPrompter.xcodeproj -scheme NotchPrompter -configuration Debug build && open ~/Library/Developer/Xcode/DerivedData/NotchPrompter-*/Build/Products/Debug/NotchPrompter.app
```

### Option 2: If Already Built
```bash
# Find and run the existing build
open ~/Library/Developer/Xcode/DerivedData/NotchPrompter-*/Build/Products/Debug/NotchPrompter.app
```

---

## Build Commands

### Debug Build (for development)
```bash
cd /path/to/notch-prompter

# Build debug version
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Debug \
  build
```

### Release Build (for distribution)
```bash
cd /path/to/notch-prompter

# Build release version (optimized)
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Release \
  build
```

### Clean Build
```bash
# Clean previous builds
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  clean

# Then rebuild
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Release \
  build
```

---

## Create Distributable App (.app bundle)

### Step 1: Archive the Application
```bash
cd /path/to/notch-prompter

# Create an archive
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Release \
  -archivePath ./build/NotchPrompter.xcarchive \
  archive
```

### Step 2: Export the App Bundle
```bash
# Create export options plist first
cat > ./build/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export the app
xcodebuild -exportArchive \
  -archivePath ./build/NotchPrompter.xcarchive \
  -exportPath ./build/Export \
  -exportOptionsPlist ./build/ExportOptions.plist
```

### Step 3: Copy to Applications (Optional)
```bash
# Copy to Applications folder
cp -R ./build/Export/NotchPrompter.app /Applications/

# Run from Applications
open /Applications/NotchPrompter.app
```

---

## Create DMG for Distribution

### Using hdiutil (built-in macOS tool)
```bash
cd /path/to/notch-prompter

# First, build the release app
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Release \
  CONFIGURATION_BUILD_DIR=./build/Release \
  build

# Create a temporary folder for DMG contents
mkdir -p ./build/dmg-contents
cp -R ./build/Release/NotchPrompter.app ./build/dmg-contents/

# Create a symbolic link to Applications folder
ln -s /Applications ./build/dmg-contents/Applications

# Create the DMG
hdiutil create -volname "Notch Prompter" \
  -srcfolder ./build/dmg-contents \
  -ov -format UDZO \
  ./build/NotchPrompter.dmg

# Clean up
rm -rf ./build/dmg-contents

echo "DMG created at: ./build/NotchPrompter.dmg"
```

---

## All-in-One Build Script

Create and run this script to build everything:

```bash
#!/bin/bash
# Save as: build.sh

set -e  # Exit on error

PROJECT_DIR="/path/to/notch-prompter"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== Notch Prompter Build Script ==="

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build Release
echo "Building Release version..."
cd "$PROJECT_DIR"
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Release \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR/Release" \
  build

# Create DMG
echo "Creating DMG..."
mkdir -p "$BUILD_DIR/dmg-contents"
cp -R "$BUILD_DIR/Release/NotchPrompter.app" "$BUILD_DIR/dmg-contents/"
ln -s /Applications "$BUILD_DIR/dmg-contents/Applications"

hdiutil create -volname "Notch Prompter" \
  -srcfolder "$BUILD_DIR/dmg-contents" \
  -ov -format UDZO \
  "$BUILD_DIR/NotchPrompter.dmg"

rm -rf "$BUILD_DIR/dmg-contents"

echo ""
echo "=== Build Complete ==="
echo "App location: $BUILD_DIR/Release/NotchPrompter.app"
echo "DMG location: $BUILD_DIR/NotchPrompter.dmg"
echo ""
echo "To run the app:"
echo "  open $BUILD_DIR/Release/NotchPrompter.app"
```

### Make it executable and run:
```bash
# Create the script
cd /path/to/notch-prompter
chmod +x build.sh

# Run it
./build.sh
```

---

## Useful Terminal Commands

### Run App
```bash
# Run from DerivedData (after xcodebuild)
open ~/Library/Developer/Xcode/DerivedData/NotchPrompter-*/Build/Products/Debug/NotchPrompter.app

# Run from custom build directory
open ./build/Release/NotchPrompter.app

# Run from Applications
open /Applications/NotchPrompter.app
```

### Check Build Status
```bash
# List available schemes
xcodebuild -project NotchPrompter.xcodeproj -list

# Show build settings
xcodebuild -project NotchPrompter.xcodeproj -scheme NotchPrompter -showBuildSettings
```

### Find Built App
```bash
# Find in DerivedData
find ~/Library/Developer/Xcode/DerivedData -name "NotchPrompter.app" -type d 2>/dev/null
```

### Kill Running App
```bash
# Force quit if running
pkill -f NotchPrompter || true
```

### View App Logs
```bash
# Stream logs from the app
log stream --predicate 'subsystem == "com.radhakishanjangid.notchprompter"' --level debug
```

---

## Requirements

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **Command Line Tools**: Install with `xcode-select --install`

---

## Troubleshooting

### "xcodebuild: command not found"
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### "No scheme found"
```bash
# List available schemes
xcodebuild -project NotchPrompter.xcodeproj -list

# Use the exact scheme name shown
```

### Build Errors
```bash
# Clean and rebuild
xcodebuild -project NotchPrompter.xcodeproj -scheme NotchPrompter clean
xcodebuild -project NotchPrompter.xcodeproj -scheme NotchPrompter build
```

### Code Signing Issues
For local development without a paid Apple Developer account:
```bash
# Build with automatic signing for local use
xcodebuild -project NotchPrompter.xcodeproj \
  -scheme NotchPrompter \
  -configuration Debug \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  build
```

---

## Project Info

- **Bundle ID**: com.radhakishanjangid.notchprompter
- **Minimum macOS**: 13.0
- **Architecture**: Universal (Apple Silicon + Intel)
- **Framework**: SwiftUI + AppKit
