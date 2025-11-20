#!/bin/bash
#
# Test runner script for Tank Game
# Compiles and runs basic logic tests for the core game components
#

set -e

echo "🎮 Tank Game Test Runner"
echo "========================"
echo ""

# Change to script directory
cd "$(dirname "$0")"

# Clean up any previous test builds
rm -f /tmp/test_runner

echo "📦 Compiling tests..."
swiftc -o /tmp/test_runner \
  "tankgame Shared/Direction.swift" \
  "tankgame Shared/GridCell.swift" \
  "tankgame Shared/Tank.swift" \
  "tankgame Shared/Projectile.swift" \
  "tankgame Tests/GameLogicTests.swift"

echo "✓ Compilation successful"
echo ""

echo "🧪 Running tests..."
echo ""
/tmp/test_runner

echo ""
echo "✨ Test run complete!"
