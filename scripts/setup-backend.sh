#!/bin/bash

# Setup script for backend development

set -e

echo "🚀 Setting up Drug Interaction Checker Backend..."

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK not found. Please install .NET 8.0 SDK"
    echo "Visit: https://dotnet.microsoft.com/download"
    exit 1
fi

echo "✅ .NET SDK found: $(dotnet --version)"

# Navigate to backend directory
cd "$(dirname "$0")/../backend/DrugInteractionAPI"

# Restore dependencies
echo "📦 Restoring NuGet packages..."
dotnet restore

# Build project
echo "🔨 Building project..."
dotnet build --configuration Debug

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    echo ""
    echo "🐳 Docker Compose detected!"
    echo "To start PostgreSQL and Redis, run:"
    echo "  cd ../.. && docker-compose -f backend/docker-compose.yml up -d"
else
    echo ""
    echo "⚠️  Docker Compose not found. You'll need to set up PostgreSQL and Redis manually."
fi

echo ""
echo "✅ Backend setup complete!"
echo ""
echo "Next steps:"
echo "1. Update appsettings.json with your configuration"
echo "2. Start database: docker-compose up -d (in backend/ directory)"
echo "3. Run migrations: dotnet ef database update"
echo "4. Run application: dotnet run"
echo ""
echo "API will be available at: https://localhost:5001"