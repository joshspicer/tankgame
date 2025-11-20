#!/bin/bash
# Multiplayer Testing Helper Script
# This script helps set up and run the tank game on multiple devices for multiplayer testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "Tank Game Multiplayer Testing Helper"
echo "======================================"
echo ""

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    print_error "xcodebuild not found. Please install Xcode."
    exit 1
fi

# Check if xcrun is available
if ! command -v xcrun &> /dev/null; then
    print_error "xcrun not found. Please install Xcode Command Line Tools."
    exit 1
fi

print_info "Checking for connected devices..."
echo ""

# List all connected devices
DEVICES=$(xcrun xctrace list devices 2>&1 | grep -E "^[A-Za-z].*\([0-9A-F]{8}-" | grep -v "Simulator")

if [ -z "$DEVICES" ]; then
    print_error "No physical devices connected!"
    echo ""
    echo "To test multiplayer, you need to:"
    echo "  1. Connect at least 2 iOS devices via USB or wireless debugging"
    echo "  2. Ensure devices are on the same local network"
    echo "  3. Trust the development certificate on all devices"
    echo ""
    print_warning "iOS Simulators do NOT support MultipeerConnectivity!"
    print_warning "See SIMULATOR_TESTING.md for more information."
    echo ""
    exit 1
fi

echo "Connected devices:"
echo "$DEVICES"
echo ""

# Count devices
DEVICE_COUNT=$(echo "$DEVICES" | wc -l | tr -d ' ')
print_info "Found $DEVICE_COUNT device(s)"

if [ "$DEVICE_COUNT" -lt 2 ]; then
    print_warning "Only $DEVICE_COUNT device connected. You need at least 2 devices for multiplayer testing."
    echo ""
    echo "Current device:"
    echo "$DEVICES"
    echo ""
    exit 1
fi

echo ""
print_info "Great! You have $DEVICE_COUNT devices connected."
print_info "This is enough for multiplayer testing (2-4 players supported)."
echo ""

# Ask user if they want to build and deploy
read -p "Do you want to build and deploy to all connected devices? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Skipping build. You can manually build and run from Xcode."
    echo ""
    echo "Manual steps:"
    echo "  1. Open tankgame.xcodeproj in Xcode"
    echo "  2. Select the tankgame iOS scheme"
    echo "  3. For each device:"
    echo "     - Select device as destination"
    echo "     - Click Run (⌘R)"
    echo "  4. On one device: tap 'Host Game'"
    echo "  5. On other devices: tap 'Join Game'"
    echo ""
    exit 0
fi

print_info "Building for iOS devices..."
echo ""

# Build the project
xcodebuild -project tankgame.xcodeproj \
    -scheme "tankgame iOS" \
    -configuration Debug \
    -sdk iphoneos \
    clean build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | grep -E "error:|warning:|Succeeded|Failed" || true

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    print_error "Build failed! Check the output above for details."
    exit 1
fi

print_info "Build completed successfully!"
echo ""

print_info "To deploy and test:"
echo ""
echo "1. In Xcode, select 'tankgame iOS' scheme"
echo "2. Deploy to each device:"
while IFS= read -r device; do
    device_name=$(echo "$device" | sed 's/(.*//' | xargs)
    echo "   - Select device: $device_name"
done <<< "$DEVICES"
echo "3. Run the app on all devices (⌘R for each)"
echo ""
echo "Testing steps:"
echo "  1. On Device 1: Tap 'Host Game'"
echo "  2. On Device 2+: Tap 'Join Game'"
echo "  3. On Device 2+: Select the host from the list"
echo "  4. On Device 1: Tap 'Start Game' when all players connected"
echo "  5. Test gameplay, messaging, and synchronization"
echo ""

print_info "Multiplayer testing checklist:"
echo "  ☐ Peer discovery works"
echo "  ☐ Connection established successfully"
echo "  ☐ All devices see each other"
echo "  ☐ Game starts on all devices simultaneously"
echo "  ☐ Tank movements synchronized"
echo "  ☐ Projectile firing synchronized"
echo "  ☐ Collisions detected correctly"
echo "  ☐ Scores updated on all devices"
echo "  ☐ Round transitions work"
echo "  ☐ Disconnection handled gracefully"
echo ""

print_info "Done! Happy testing! 🎮"
