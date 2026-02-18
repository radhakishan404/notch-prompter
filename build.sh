#!/bin/bash
#
# Notch Prompter Build Script
# Creates a distributable .app and .dmg
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
PROJECT_NAME="NotchPrompter"
APP_NAME="NotchPrompter"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║     Notch Prompter Build Script          ║"
echo "║     Free & Open Source Teleprompter          ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. Please install Xcode Command Line Tools:${NC}"
    echo "  xcode-select --install"
    exit 1
fi

# Parse arguments
BUILD_TYPE="release"
CREATE_DMG=true
OPEN_APP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            BUILD_TYPE="debug"
            shift
            ;;
        --no-dmg)
            CREATE_DMG=false
            shift
            ;;
        --run)
            OPEN_APP=true
            shift
            ;;
        --help|-h)
            echo "Usage: ./build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --debug     Build debug version (default: release)"
            echo "  --no-dmg    Skip DMG creation"
            echo "  --run       Open the app after building"
            echo "  --help      Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Set configuration
if [ "$BUILD_TYPE" = "debug" ]; then
    CONFIGURATION="Debug"
else
    CONFIGURATION="Release"
fi

echo -e "${YELLOW}Configuration: $CONFIGURATION${NC}"
echo ""

# Step 1: Clean previous builds
echo -e "${BLUE}[1/4] Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
echo -e "${GREEN}✓ Clean complete${NC}"

# Step 2: Build the app
echo -e "${BLUE}[2/4] Building $APP_NAME ($CONFIGURATION)...${NC}"
cd "$PROJECT_DIR"

xcodebuild -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration "$CONFIGURATION" \
    CONFIGURATION_BUILD_DIR="$BUILD_DIR/$CONFIGURATION" \
    CODE_SIGN_IDENTITY="-" \
    build 2>&1 | grep -E "(Building|Compiling|Linking|error:|warning:|\*\*)" || true

if [ -d "$BUILD_DIR/$CONFIGURATION/$APP_NAME.app" ]; then
    echo -e "${GREEN}✓ Build successful${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

# Step 3: Create DMG (optional)
if [ "$CREATE_DMG" = true ]; then
    echo -e "${BLUE}[3/4] Creating DMG...${NC}"

    DMG_CONTENTS="$BUILD_DIR/dmg-contents"
    mkdir -p "$DMG_CONTENTS"

    # Copy app
    cp -R "$BUILD_DIR/$CONFIGURATION/$APP_NAME.app" "$DMG_CONTENTS/"

    # Create Applications symlink
    ln -s /Applications "$DMG_CONTENTS/Applications"

    # Create DMG
    hdiutil create -volname "Notch Prompter" \
        -srcfolder "$DMG_CONTENTS" \
        -ov -format UDZO \
        "$BUILD_DIR/NotchPrompter.dmg" > /dev/null 2>&1

    # Cleanup
    rm -rf "$DMG_CONTENTS"

    echo -e "${GREEN}✓ DMG created${NC}"
else
    echo -e "${YELLOW}[3/4] Skipping DMG creation${NC}"
fi

# Step 4: Summary
echo -e "${BLUE}[4/4] Build complete!${NC}"
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              BUILD SUCCESSFUL                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${YELLOW}App:${NC} $BUILD_DIR/$CONFIGURATION/$APP_NAME.app"
if [ "$CREATE_DMG" = true ]; then
    echo -e "  ${YELLOW}DMG:${NC} $BUILD_DIR/NotchPrompter.dmg"
fi
echo ""
echo -e "${BLUE}To run the app:${NC}"
echo "  open \"$BUILD_DIR/$CONFIGURATION/$APP_NAME.app\""
echo ""
echo -e "${BLUE}To install:${NC}"
echo "  cp -R \"$BUILD_DIR/$CONFIGURATION/$APP_NAME.app\" /Applications/"
echo ""

# Open app if requested
if [ "$OPEN_APP" = true ]; then
    echo -e "${BLUE}Opening app...${NC}"
    open "$BUILD_DIR/$CONFIGURATION/$APP_NAME.app"
fi
