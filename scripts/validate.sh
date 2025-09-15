#!/bin/bash

# Nen-Core Validation Script
# Validates the build, tests, and examples

set -e

echo "🔍 Validating nen-core..."

# Check if zig is installed
if ! command -v zig &> /dev/null; then
    echo "❌ Zig is not installed. Please install Zig 0.15.1 or later."
    exit 1
fi

echo "✅ Zig is installed: $(zig version)"

# Build all configurations
echo "🔨 Building all configurations..."
zig build -Doptimize=Debug
zig build -Doptimize=ReleaseSafe
zig build -Doptimize=ReleaseFast
echo "✅ All builds completed"

# Run tests
echo "🧪 Running tests..."
zig build test
echo "✅ All tests passed"

# Run examples
echo "📚 Running examples..."
zig build run-numerical
zig build run-memory
zig build run-unified
zig build run-batching
zig build run-inline
zig build run-release
echo "✅ All examples completed"

# Format check
echo "🎨 Checking code formatting..."
zig fmt --check .
echo "✅ Code formatting is correct"

# Check for common issues
echo "🔍 Checking for common issues..."

# Check for debug prints
if grep -r "std.debug.print" src/ examples/ tests/; then
    echo "⚠️ Found debug prints - consider removing for production"
else
    echo "✅ No debug prints found"
fi

# Check for TODO/FIXME
if grep -r "TODO\|FIXME" src/ examples/ tests/; then
    echo "⚠️ Found TODO/FIXME comments - please address them"
else
    echo "✅ No TODO/FIXME comments found"
fi

echo "🎉 All validations passed!"
