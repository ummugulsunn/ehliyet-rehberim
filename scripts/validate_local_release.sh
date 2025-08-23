#!/bin/bash

# Local Release Build Validation Script
# Validates local release build configuration and functionality

set -e

echo "🔍 Local Release Build Validation"
echo "=================================="

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

# Validation results
VALIDATION_PASSED=true

# Function to mark validation as failed
mark_failed() {
    VALIDATION_PASSED=false
    print_error "$1"
}

# Function to validate file exists
validate_file() {
    if [ -f "$1" ]; then
        print_status "$2 found"
        return 0
    else
        mark_failed "$2 not found at $1"
        return 1
    fi
}

echo "1. Validating project structure..."

# Check if we're in the Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    mark_failed "Not in Flutter project directory. Please run from project root."
    exit 1
fi

print_status "Flutter project structure validated"

echo ""
echo "2. Validating keystore configuration..."

# Check keystore file
KEYSTORE_PATH="android/app/ehliyet-rehberim-key.jks"
validate_file "$KEYSTORE_PATH" "Release keystore"

# Check key.properties file
KEY_PROPERTIES_PATH="android/key.properties"
if validate_file "$KEY_PROPERTIES_PATH" "Key properties file"; then
    # Validate key.properties content
    if grep -q "storeFile=" "$KEY_PROPERTIES_PATH" && \
       grep -q "storePassword=" "$KEY_PROPERTIES_PATH" && \
       grep -q "keyAlias=" "$KEY_PROPERTIES_PATH" && \
       grep -q "keyPassword=" "$KEY_PROPERTIES_PATH"; then
        print_status "Key properties file contains required fields"
    else
        mark_failed "Key properties file missing required fields"
    fi
fi

echo ""
echo "3. Validating Firebase configuration..."

# Check google-services.json
validate_file "android/app/google-services.json" "Android Firebase configuration"

# Check GoogleService-Info.plist
validate_file "ios/Runner/GoogleService-Info.plist" "iOS Firebase configuration"

# Validate package name in google-services.json
if [ -f "android/app/google-services.json" ]; then
    PACKAGE_NAME=$(grep -o '"package_name": *"[^"]*"' android/app/google-services.json | head -1 | cut -d'"' -f4)
    if [ "$PACKAGE_NAME" = "com.ehliyetrehberim.app" ]; then
        print_status "Package name in google-services.json is correct: $PACKAGE_NAME"
    else
        mark_failed "Package name in google-services.json is incorrect: $PACKAGE_NAME (expected: com.ehliyetrehberim.app)"
    fi
fi

echo ""
echo "4. Validating build configuration..."

# Check build.gradle configuration
BUILD_GRADLE_PATH="android/app/build.gradle.kts"
if validate_file "$BUILD_GRADLE_PATH" "Build configuration"; then
    # Check if google-services plugin is applied
    if grep -q "google-services" "$BUILD_GRADLE_PATH"; then
        print_status "Google Services plugin configured"
    else
        mark_failed "Google Services plugin not found in build.gradle.kts"
    fi
    
    # Check signing configuration
    if grep -q "signingConfigs" "$BUILD_GRADLE_PATH"; then
        print_status "Signing configuration found"
    else
        mark_failed "Signing configuration not found in build.gradle.kts"
    fi
fi

echo ""
echo "5. Validating dependencies..."

# Check pubspec.yaml for required dependencies
PUBSPEC_PATH="pubspec.yaml"
if validate_file "$PUBSPEC_PATH" "Flutter dependencies"; then
    REQUIRED_DEPS=("firebase_auth" "google_sign_in" "firebase_core")
    
    for dep in "${REQUIRED_DEPS[@]}"; do
        if grep -q "$dep:" "$PUBSPEC_PATH"; then
            print_status "$dep dependency found"
        else
            mark_failed "$dep dependency not found in pubspec.yaml"
        fi
    done
fi

echo ""
echo "6. Testing keystore access..."

if [ -f "$KEYSTORE_PATH" ]; then
    echo "Testing keystore access (you may be prompted for password)..."
    
    # Try to list keystore contents
    if keytool -list -keystore "$KEYSTORE_PATH" -alias key >/dev/null 2>&1; then
        print_status "Keystore access successful"
    else
        print_warning "Could not access keystore. Please verify password and alias."
        print_info "This may cause release build to fail."
    fi
fi

echo ""
echo "7. Validating Flutter environment..."

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -1)
print_info "Flutter version: $FLUTTER_VERSION"

# Check if Flutter doctor passes
echo "Running Flutter doctor..."
if flutter doctor --android-licenses >/dev/null 2>&1; then
    print_status "Android licenses accepted"
else
    print_warning "Android licenses may need to be accepted"
fi

echo ""
echo "8. Testing build process (dry run)..."

# Clean and get dependencies
flutter clean >/dev/null 2>&1
flutter pub get >/dev/null 2>&1

# Test if build would succeed (without actually building)
echo "Validating build configuration..."
if flutter build apk --release --dry-run >/dev/null 2>&1; then
    print_status "Build configuration is valid"
else
    mark_failed "Build configuration has issues"
fi

echo ""
echo "9. Validating authentication service..."

# Check if auth service exists and is properly configured
AUTH_SERVICE_PATH="lib/src/core/services/auth_service.dart"
if validate_file "$AUTH_SERVICE_PATH" "Authentication service"; then
    # Check for Google Sign-In implementation
    if grep -q "GoogleSignIn" "$AUTH_SERVICE_PATH"; then
        print_status "Google Sign-In implementation found"
    else
        mark_failed "Google Sign-In implementation not found in auth service"
    fi
    
    # Check for error handling
    if grep -q "FirebaseAuthException\|PlatformException" "$AUTH_SERVICE_PATH"; then
        print_status "Error handling implementation found"
    else
        print_warning "Error handling may be incomplete in auth service"
    fi
fi

echo ""
echo "10. Validation summary:"
echo "======================"

if [ "$VALIDATION_PASSED" = true ]; then
    print_status "All validations passed!"
    echo ""
    echo "✅ Your local release build configuration is ready."
    echo "You can proceed with building the release APK."
    echo ""
    echo "Next steps:"
    echo "1. Run './scripts/test_release_build.sh' to build and test release APK"
    echo "2. Test Google Sign-In functionality on a physical device"
    echo "3. Verify all app features work correctly in release mode"
    
    exit 0
else
    print_error "Some validations failed!"
    echo ""
    echo "❌ Please fix the issues above before building release APK."
    echo ""
    echo "Common fixes:"
    echo "- Ensure keystore file exists and is accessible"
    echo "- Verify Firebase configuration files are up to date"
    echo "- Check that all required dependencies are in pubspec.yaml"
    echo "- Run 'flutter doctor' to fix Flutter environment issues"
    
    exit 1
fi