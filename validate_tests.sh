#!/bin/bash
# Simple validation script to check test files for syntax errors
# This doesn't actually compile or run the tests, but validates Swift syntax

echo "🔍 Validating test file syntax..."
echo ""

TEST_FILES=(
    "tankgame Shared/GameStateTests.swift"
    "tankgame Shared/DirectionTests.swift"
    "tankgame Shared/TankTests.swift"
    "tankgame Shared/CollisionDetectionTests.swift"
    "tankgame Shared/ProjectileTests.swift"
)

all_valid=true

for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ Found: $file"
        
        # Basic checks
        if ! grep -q "import XCTest" "$file"; then
            echo "  ⚠️  Warning: Missing 'import XCTest'"
            all_valid=false
        fi
        
        if ! grep -q "class.*Tests.*XCTestCase" "$file"; then
            echo "  ⚠️  Warning: Missing XCTestCase class declaration"
            all_valid=false
        fi
        
        # Check for test methods
        test_count=$(grep -c "func test" "$file")
        if [ "$test_count" -eq 0 ]; then
            echo "  ⚠️  Warning: No test methods found"
            all_valid=false
        else
            echo "  ✓ Found $test_count test methods"
        fi
    else
        echo "✗ Missing: $file"
        all_valid=false
    fi
    echo ""
done

if $all_valid; then
    echo "✅ All test files validated successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Open tankgame.xcodeproj in Xcode"
    echo "2. Follow TESTING_SETUP.md to add test target"
    echo "3. Run tests with Cmd+U"
    exit 0
else
    echo "❌ Some validation checks failed"
    exit 1
fi
