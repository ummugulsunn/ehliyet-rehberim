#!/bin/bash

# Release Build Test Script
# Creates and tests release APK with Google Sign-In functionality

set -e

echo "🚀 Release Build Test Script"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if we're in the Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory. Please run from project root."
    exit 1
fi

echo "1. Checking Flutter environment..."
flutter doctor --verbose

echo ""
echo "2. Validating release keystore..."
KEYSTORE_PATH="android/app/ehliyet-rehberim-key.jks"

if [ ! -f "$KEYSTORE_PATH" ]; then
    print_error "Release keystore not found at $KEYSTORE_PATH"
    print_info "Please ensure the keystore file exists and is properly configured"
    exit 1
fi

print_status "Release keystore found"

echo ""
echo "3. Extracting release SHA-1 fingerprint..."
echo "Please enter the keystore password when prompted:"

# Extract SHA-1 from release keystore
RELEASE_SHA1=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias key 2>/dev/null | grep "SHA1:" | cut -d' ' -f3)

if [ -n "$RELEASE_SHA1" ]; then
    print_status "Release SHA-1 fingerprint: $RELEASE_SHA1"
    echo "$RELEASE_SHA1" > release_sha1.txt
else
    print_error "Could not extract release SHA-1 fingerprint"
    print_info "Please check keystore password and alias name"
    exit 1
fi

echo ""
echo "4. Validating Firebase configuration for release..."
if [ -f "android/app/google-services.json" ]; then
    print_status "google-services.json found"
    
    # Check if release SHA-1 is in the configuration
    if grep -q "$RELEASE_SHA1" android/app/google-services.json; then
        print_status "Release SHA-1 found in google-services.json"
    else
        print_error "Release SHA-1 NOT found in google-services.json"
        print_info "This will cause Google Sign-In to fail in release builds"
        print_info "Please add the release SHA-1 to Firebase Console and download updated google-services.json"
        
        echo ""
        echo "🔧 To fix this issue:"
        echo "1. Go to Firebase Console > Project Settings > Your Apps > Android App"
        echo "2. Add SHA certificate fingerprint: $RELEASE_SHA1"
        echo "3. Download the updated google-services.json"
        echo "4. Replace android/app/google-services.json with the new file"
        echo ""
        
        read -p "Do you want to continue with the build anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    print_error "google-services.json not found in android/app/"
    exit 1
fi

echo ""
echo "5. Getting dependencies..."
flutter pub get

echo ""
echo "6. Cleaning previous builds..."
flutter clean

echo ""
echo "7. Running pre-build tests..."
flutter test test/core/services/auth_service_test.dart

echo ""
echo "8. Building release APK..."
print_info "This may take several minutes..."

flutter build apk --release

if [ $? -eq 0 ]; then
    print_status "Release APK built successfully"
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    
    if [ -f "$APK_PATH" ]; then
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        print_status "Release APK location: $APK_PATH"
        print_status "Release APK size: $APK_SIZE"
        
        # Create a timestamped copy
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_PATH="build/app-release-$TIMESTAMP.apk"
        cp "$APK_PATH" "$BACKUP_PATH"
        print_status "Backup created: $BACKUP_PATH"
    fi
else
    print_error "Release APK build failed"
    exit 1
fi

echo ""
echo "9. Analyzing release APK..."
if command -v aapt &> /dev/null; then
    echo "APK Information:"
    aapt dump badging "$APK_PATH" | grep -E "(package|application-label|uses-permission)"
    
    echo ""
    echo "APK Contents:"
    aapt list "$APK_PATH" | grep -E "(google-services|firebase|auth)" | head -10
else
    print_warning "aapt not found. Skipping APK analysis."
fi

echo ""
echo "10. Verifying APK signature..."
if command -v jarsigner &> /dev/null; then
    jarsigner -verify -verbose -certs "$APK_PATH" | head -20
    
    if jarsigner -verify "$APK_PATH" &> /dev/null; then
        print_status "APK signature verified"
    else
        print_error "APK signature verification failed"
    fi
else
    print_warning "jarsigner not found. Skipping signature verification."
fi

echo ""
echo "11. Testing release APK installation..."
if command -v adb &> /dev/null; then
    # Check if device is connected
    DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)
    
    if [ "$DEVICES" -gt 0 ]; then
        print_status "Android device/emulator detected"
        
        # Uninstall previous version if exists
        echo "Uninstalling previous version..."
        adb uninstall com.ehliyetrehberim.app 2>/dev/null || true
        
        # Install release APK
        echo "Installing release APK..."
        adb install "$APK_PATH"
        
        if [ $? -eq 0 ]; then
            print_status "Release APK installed successfully"
            
            # Launch the app
            echo "Launching the app..."
            adb shell am start -n com.ehliyetrehberim.app/com.ehliyetrehberim.app.MainActivity
            
            print_info "App launched. Please test Google Sign-In manually."
        else
            print_error "Release APK installation failed"
        fi
    else
        print_warning "No Android device/emulator connected."
        print_info "Please connect a device to test the release APK."
    fi
else
    print_warning "ADB not found. Skipping device installation."
fi

echo ""
echo "12. Release build test summary:"
echo "=============================="
print_status "Release APK built successfully"
print_status "SHA-1 fingerprint extracted: $RELEASE_SHA1"
print_status "APK location: $APK_PATH"

echo ""
echo "📋 Manual Testing Checklist for Release Build:"
echo "- Install the release APK on a test device"
echo "- Open the app and navigate to authentication"
echo "- Test Google Sign-In functionality"
echo "- Verify successful authentication with Google account"
echo "- Test sign-out functionality"
echo "- Test app functionality with authenticated user"
echo "- Verify no debug-specific features are present"

echo ""
echo "🔍 If Google Sign-In fails:"
echo "- Check that release SHA-1 ($RELEASE_SHA1) is added to Firebase Console"
echo "- Verify google-services.json is updated with the new SHA-1"
echo "- Ensure the app is signed with the correct keystore"
echo "- Check device internet connection"

echo ""
print_status "Release build test completed!"