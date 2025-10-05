#!/bin/bash

# Setup script for mobile development

set -e

echo "📱 Setting up Drug Interaction Checker Mobile App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Navigate to mobile directory
cd "$(dirname "$0")/../mobile"

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Generate code
echo "🔨 Generating model code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Check Flutter doctor
echo ""
echo "🏥 Running Flutter doctor..."
flutter doctor

echo ""
echo "✅ Mobile app setup complete!"
echo ""
echo "Next steps:"
echo "1. Update lib/services/api_service.dart with your API URL"
echo "2. Configure Google Sign-In credentials"
echo "3. Configure AdMob ad units"
echo "4. Run: flutter run"
echo ""
echo "For Android emulator: flutter run"
echo "For iOS simulator: flutter run -d ios"