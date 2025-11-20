#!/bin/bash
# Run script for Tank Game
# This script builds and launches the Tank Game on iOS or tvOS simulators, or natively on macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PLATFORM="iOS"
CONFIGURATION="Debug"
INSTANCES=1
DEVICE=""

# Function to display usage
usage() {
    echo "Usage: $0 [-p platform] [-c configuration] [-n instances] [-d device]"
    echo ""
    echo "Options:"
    echo "  -p platform       Platform to run: iOS, macOS, or tvOS (default: iOS)"
    echo "  -c configuration  Build configuration: Debug or Release (default: Debug)"
    echo "  -n instances      Number of instances to launch (1 or 2, for multiplayer testing) (default: 1)"
    echo "  -d device         Specific simulator device name (e.g., 'iPhone 15 Pro')"
    echo "  -h                Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run iOS on default simulator"
    echo "  $0 -n 2                      # Run 2 iOS instances for multiplayer"
    echo "  $0 -p macOS                  # Run on macOS natively"
    echo "  $0 -d 'iPhone 15 Pro'        # Run on specific simulator"
    echo "  $0 -p iOS -n 2 -d 'iPhone 15 Pro' # Run 2 instances on specific device"
    exit 1
}

# Parse command line arguments
while getopts "p:c:n:d:h" opt; do
    case $opt in
        p)
            PLATFORM="$OPTARG"
            ;;
        c)
            CONFIGURATION="$OPTARG"
            ;;
        n)
            INSTANCES="$OPTARG"
            ;;
        d)
            DEVICE="$OPTARG"
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

# Validate instances
if [ "$INSTANCES" != "1" ] && [ "$INSTANCES" != "2" ]; then
    echo -e "${RED}Error: Number of instances must be 1 or 2.${NC}"
    usage
fi

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: xcodebuild not found. This script requires Xcode to be installed.${NC}"
    exit 1
fi

# Check if xcrun is available (for simulator operations)
if ! command -v xcrun &> /dev/null; then
    echo -e "${RED}Error: xcrun not found. This script requires Xcode Command Line Tools.${NC}"
    exit 1
fi

# Build the project first
echo -e "${GREEN}Building Tank Game for $PLATFORM ($CONFIGURATION)...${NC}"
xcodebuild \
    -project tankgame.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk "$SDK" \
    -derivedDataPath ./build \
    build

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful!${NC}"
echo ""

# Get the app path
if [ "$PLATFORM" == "macOS" ]; then
    APP_PATH="./build/Build/Products/$CONFIGURATION/Tank Game.app"
else
    APP_PATH="./build/Build/Products/$CONFIGURATION-$SDK/Tank Game.app"
fi

# Verify app exists
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: App not found at $APP_PATH${NC}"
    exit 1
fi

# Launch based on platform
if [ "$PLATFORM" == "macOS" ]; then
    echo -e "${BLUE}Launching Tank Game on macOS...${NC}"
    
    for i in $(seq 1 $INSTANCES); do
        if [ "$INSTANCES" == "2" ]; then
            echo -e "${YELLOW}Launching instance $i...${NC}"
        fi
        open -n "$APP_PATH"
        if [ "$INSTANCES" == "2" ]; then
            sleep 2  # Give some time between launches
        fi
    done
    
    echo -e "${GREEN}Tank Game launched successfully!${NC}"
else
    # iOS or tvOS - use simulator
    echo -e "${BLUE}Launching Tank Game on $PLATFORM Simulator...${NC}"
    
    # Get available simulators
    if [ -z "$DEVICE" ]; then
        # Find a booted simulator or boot a default one
        if [ "$PLATFORM" == "iOS" ]; then
            DEVICE=$(xcrun simctl list devices available | grep "iPhone" | grep -v "unavailable" | head -1 | sed 's/.*(\([^)]*\)).*/\1/' | xargs)
            DEVICE_NAME="iPhone"
        else
            DEVICE=$(xcrun simctl list devices available | grep "Apple TV" | grep -v "unavailable" | head -1 | sed 's/.*(\([^)]*\)).*/\1/' | xargs)
            DEVICE_NAME="Apple TV"
        fi
        
        if [ -z "$DEVICE" ]; then
            echo -e "${RED}Error: No available $PLATFORM simulators found.${NC}"
            exit 1
        fi
    else
        # Use specified device
        DEVICE=$(xcrun simctl list devices available | grep "$DEVICE" | head -1 | sed 's/.*(\([^)]*\)).*/\1/' | xargs)
        if [ -z "$DEVICE" ]; then
            echo -e "${RED}Error: Device '$DEVICE' not found.${NC}"
            echo -e "${YELLOW}Available devices:${NC}"
            xcrun simctl list devices available
            exit 1
        fi
        DEVICE_NAME="$DEVICE"
    fi
    
    # Launch instances
    for i in $(seq 1 $INSTANCES); do
        if [ "$INSTANCES" == "2" ]; then
            echo -e "${YELLOW}Launching instance $i on simulator...${NC}"
            
            # For second instance, try to use a different device
            if [ "$i" == "2" ]; then
                if [ "$PLATFORM" == "iOS" ]; then
                    DEVICE2=$(xcrun simctl list devices available | grep "iPhone" | grep -v "unavailable" | sed -n '2p' | sed 's/.*(\([^)]*\)).*/\1/' | xargs)
                else
                    DEVICE2=$(xcrun simctl list devices available | grep "Apple TV" | grep -v "unavailable" | sed -n '2p' | sed 's/.*(\([^)]*\)).*/\1/' | xargs)
                fi
                
                if [ ! -z "$DEVICE2" ]; then
                    DEVICE="$DEVICE2"
                    echo -e "${YELLOW}Using second simulator: $DEVICE${NC}"
                fi
            fi
        fi
        
        # Boot simulator if not already booted
        xcrun simctl boot "$DEVICE" 2>/dev/null || true
        
        # Open simulator app
        open -a Simulator
        
        # Wait for simulator to be ready
        sleep 2
        
        # Install and launch app
        xcrun simctl install "$DEVICE" "$APP_PATH"
        xcrun simctl launch "$DEVICE" "com.joshspicer.tankgame"
        
        if [ "$INSTANCES" == "2" ] && [ "$i" == "1" ]; then
            sleep 3  # Give time between instances
        fi
    done
    
    echo -e "${GREEN}Tank Game launched successfully on $PLATFORM Simulator!${NC}"
    
    if [ "$INSTANCES" == "2" ]; then
        echo ""
        echo -e "${YELLOW}Multiplayer Testing:${NC}"
        echo "  - Two instances are now running"
        echo "  - Use the lobby to connect the devices via Bluetooth/MultipeerConnectivity"
        echo "  - Start a game to test multiplayer functionality"
    fi
fi

echo ""
echo -e "${GREEN}Enjoy playing Tank Game! 🚀${NC}"
