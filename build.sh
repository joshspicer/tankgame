#!/bin/bash
# Build script for Tank Game
# This script builds the iOS, macOS, or tvOS version of the Tank Game

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
PLATFORM="iOS"
CONFIGURATION="Debug"
SCHEME=""

# Function to display usage
usage() {
    echo "Usage: $0 [-p platform] [-c configuration]"
    echo ""
    echo "Options:"
    echo "  -p platform       Platform to build: iOS, macOS, or tvOS (default: iOS)"
    echo "  -c configuration  Build configuration: Debug or Release (default: Debug)"
    echo "  -h                Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build iOS Debug"
    echo "  $0 -p macOS           # Build macOS Debug"
    echo "  $0 -p iOS -c Release  # Build iOS Release"
    exit 1
}

# Parse command line arguments
while getopts "p:c:h" opt; do
    case $opt in
        p)
            PLATFORM="$OPTARG"
            ;;
        c)
            CONFIGURATION="$OPTARG"
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

# Validate platform
case $PLATFORM in
    iOS|ios)
        PLATFORM="iOS"
        SCHEME="tankgame iOS"
        SDK="iphonesimulator"
        ;;
    macOS|macos)
        PLATFORM="macOS"
        SCHEME="tankgame macOS"
        SDK="macosx"
        ;;
    tvOS|tvos)
        PLATFORM="tvOS"
        SCHEME="tankgame tvOS"
        SDK="appletvsimulator"
        ;;
    *)
        echo -e "${RED}Error: Invalid platform '$PLATFORM'. Must be iOS, macOS, or tvOS.${NC}"
        usage
        ;;
esac

# Validate configuration
case $CONFIGURATION in
    Debug|Release)
        ;;
    *)
        echo -e "${RED}Error: Invalid configuration '$CONFIGURATION'. Must be Debug or Release.${NC}"
        usage
        ;;
esac

echo -e "${GREEN}Building Tank Game for $PLATFORM ($CONFIGURATION)...${NC}"

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. This script requires Xcode to be installed.${NC}"
    exit 1
fi

# Build the project
xcodebuild \
    -project tankgame.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk "$SDK" \
    -derivedDataPath ./build \
    build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    echo ""
    echo -e "${YELLOW}Build output location:${NC}"
    echo "  ./build/Build/Products/$CONFIGURATION-$SDK/"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
