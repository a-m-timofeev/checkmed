#!/bin/bash

# Deploy full stack locally using Docker

set -e

echo "🚀 Deploying Drug Interaction Checker locally..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker"
    exit 1
fi

# Navigate to backend directory
cd "$(dirname "$0")/../backend"

echo "🐳 Starting services with Docker Compose..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo ""
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "✅ Local deployment complete!"
echo ""
echo "Services:"
echo "  - API: http://localhost:5000"
echo "  - Swagger: http://localhost:5000/swagger"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis: localhost:6379"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"