#!/bin/bash

# Run all tests for the project

set -e

echo "🧪 Running Drug Interaction Checker Tests..."

# Backend tests
echo ""
echo "📊 Running Backend Tests..."
cd "$(dirname "$0")/../backend/DrugInteractionAPI.Tests"
if [ -f "DrugInteractionAPI.Tests.csproj" ]; then
    dotnet test --verbosity normal
    echo "✅ Backend tests passed"
else
    echo "⚠️  No backend tests found"
fi

# Mobile tests
echo ""
echo "📱 Running Mobile Tests..."
cd "$(dirname "$0")/../mobile"
if [ -d "test" ]; then
    flutter test
    echo "✅ Mobile tests passed"
else
    echo "⚠️  No mobile tests found"
fi

echo ""
echo "✅ All tests completed!"