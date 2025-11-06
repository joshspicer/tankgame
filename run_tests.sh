#!/bin/bash

# Test Runner Script for Tank Game
# This script runs the unit tests for the tank game project

set -e

echo "🧪 Tank Game Test Runner"
echo "========================"
echo ""

# Check if we're in the right directory
if [ ! -f "tankgame.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: tankgame.xcodeproj not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Default values
SCHEME="tankgame iOS"
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest"
COVERAGE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ios)
            SCHEME="tankgame iOS"
            DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest"
            shift
            ;;
        --macos)
            SCHEME="tankgame macOS"
            DESTINATION="platform=macOS"
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --help)
            echo "Usage: ./run_tests.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --ios       Run tests on iOS Simulator (default)"
            echo "  --macos     Run tests on macOS"
            echo "  --coverage  Enable code coverage collection"
            echo "  --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "📱 Platform: $SCHEME"
echo "🎯 Destination: $DESTINATION"
echo ""

# Build command
CMD="xcodebuild test -project tankgame.xcodeproj -scheme \"$SCHEME\" -destination \"$DESTINATION\""

# Add coverage if requested
if [ "$COVERAGE" = true ]; then
    CMD="$CMD -enableCodeCoverage YES"
    echo "📊 Code coverage: Enabled"
    echo ""
fi

# Run tests
echo "🏃 Running tests..."
echo ""
eval $CMD

# Check result
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    
    if [ "$COVERAGE" = true ]; then
        echo ""
        echo "📊 To view coverage report:"
        echo "   Open Xcode → Show Report Navigator (Cmd+9) → Coverage tab"
    fi
else
    echo ""
    echo "❌ Tests failed!"
    exit 1
fi
