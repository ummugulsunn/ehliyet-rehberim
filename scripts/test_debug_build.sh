#!/bin/bash

# Debug Build Test Script
# Tests Google Sign-In functionality in debug build

set -e

echo "🔍 Debug Build Test Script"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory. Please run from project root."
    exit 1
fi

echo "1. Checking Flutter environment..."
flutter doctor --verbose

echo ""
echo "2. Getting dependencies..."
flutter pub get

echo ""
echo "3. Cleaning previous builds..."
flutter clean

echo ""
echo "4. Extracting debug SHA-1 fingerprint..."
DEBUG_SHA1=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:" | cut -d' ' -f3)

if [ -n "$DEBUG_SHA1" ]; then
    print_status "Debug SHA-1 fingerprint: $DEBUG_SHA1"
    echo "$DEBUG_SHA1" > debug_sha1.txt
else
    print_error "Could not extract debug SHA-1 fingerprint"
    exit 1
fi

echo ""
echo "5. Validating Firebase configuration..."
if [ -f "android/app/google-services.json" ]; then
    print_status "google-services.json found"
    
    # Check if debug SHA-1 is in the configuration
    if grep -q "$DEBUG_SHA1" android/app/google-services.json; then
        print_status "Debug SHA-1 found in google-services.json"
    else
        print_warning "Debug SHA-1 not found in google-services.json - this may cause Google Sign-In issues"
    fi
else
    print_error "google-services.json not found in android/app/"
    exit 1
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_status "GoogleService-Info.plist found"
else
    print_error "GoogleService-Info.plist not found in ios/Runner/"
    exit 1
fi

echo ""
echo "6. Running unit tests..."
flutter test test/core/services/auth_service_test.dart

echo ""
echo "7. Building debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    print_status "Debug APK built successfully"
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
    
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        print_status "Debug APK location: $APK_PATH"
        print_status "Debug APK size: $APK_SIZE"
    fi
else
    print_error "Debug APK build failed"
    exit 1
fi

echo ""
echo "8. Running integration tests on debug build..."
if command -v adb &> /dev/null; then
    # Check if device is connected
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
    
    if [ "$DEVICES" -gt 0 ]; then
        print_status "Android device/emulator detected"
        
        # Install debug APK
        echo "Installing debug APK..."
        adb install -r "$APK_PATH"
        
        # Run integration tests
        echo "Running auth flow integration tests..."
        flutter test integration_test/auth_flow_integration_test.dart
        
        if [ $? -eq 0 ]; then
            print_status "Integration tests passed"
        else
            print_warning "Integration tests failed - manual testing may be required"
        fi
    else
        print_warning "No Android device/emulator connected. Skipping integration tests."
        print_warning "Please connect a device and test Google Sign-In manually."
    fi
else
    print_warning "ADB not found. Skipping device installation and integration tests."
fi

echo ""
echo "9. Debug build test summary:"
echo "=========================="
print_status "Debug APK built successfully"
print_status "SHA-1 fingerprint extracted: $DEBUG_SHA1"
print_status "Firebase configuration validated"

echo ""
echo "📋 Manual Testing Checklist:"
echo "- Install the debug APK on a test device"
echo "- Open the app and navigate to authentication"
echo "- Test Google Sign-In functionality"
echo "- Verify successful authentication"
echo "- Test sign-out functionality"

echo ""
print_status "Debug build test completed!"