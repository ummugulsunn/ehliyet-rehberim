#!/bin/bash

# SHA-1 Fingerprint Validation Script
# Validates and compares SHA-1 fingerprints for debug, release, and Play Store builds

set -e

echo "🔐 SHA-1 Fingerprint Validation"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# Arrays to store fingerprints
declare -a DEBUG_FINGERPRINTS
declare -a RELEASE_FINGERPRINTS
declare -a FIREBASE_FINGERPRINTS

echo "1. Extracting Debug SHA-1 Fingerprint..."
print_header "Debug Keystore Analysis"

DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
    print_status "Debug keystore found: $DEBUG_KEYSTORE"
    
    # Extract all fingerprints from debug keystore
    DEBUG_OUTPUT=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null)
    
    # Extract SHA-1
    DEBUG_SHA1=$(echo "$DEBUG_OUTPUT" | grep "SHA1:" | cut -d' ' -f3)
    # Extract SHA-256
    DEBUG_SHA256=$(echo "$DEBUG_OUTPUT" | grep "SHA256:" | cut -d' ' -f3)
    # Extract MD5
    DEBUG_MD5=$(echo "$DEBUG_OUTPUT" | grep "MD5:" | cut -d' ' -f3)
    
    if [ -n "$DEBUG_SHA1" ]; then
        print_status "Debug SHA-1:   $DEBUG_SHA1"
        DEBUG_FINGERPRINTS+=("$DEBUG_SHA1")
        echo "$DEBUG_SHA1" > debug_sha1.txt
    else
        print_error "Could not extract debug SHA-1"
    fi
    
    if [ -n "$DEBUG_SHA256" ]; then
        print_info "Debug SHA-256: $DEBUG_SHA256"
    fi
    
    if [ -n "$DEBUG_MD5" ]; then
        print_info "Debug MD5:     $DEBUG_MD5"
    fi
else
    print_error "Debug keystore not found at $DEBUG_KEYSTORE"
fi

echo ""
echo "2. Extracting Release SHA-1 Fingerprint..."
print_header "Release Keystore Analysis"

RELEASE_KEYSTORE="android/app/ehliyet-rehberim-key.jks"
if [ -f "$RELEASE_KEYSTORE" ]; then
    print_status "Release keystore found: $RELEASE_KEYSTORE"
    
    echo "Please enter the keystore password when prompted:"
    
    # Extract all fingerprints from release keystore
    RELEASE_OUTPUT=$(keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias key 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        # Extract SHA-1
        RELEASE_SHA1=$(echo "$RELEASE_OUTPUT" | grep "SHA1:" | cut -d' ' -f3)
        # Extract SHA-256
        RELEASE_SHA256=$(echo "$RELEASE_OUTPUT" | grep "SHA256:" | cut -d' ' -f3)
        # Extract MD5
        RELEASE_MD5=$(echo "$RELEASE_OUTPUT" | grep "MD5:" | cut -d' ' -f3)
        
        if [ -n "$RELEASE_SHA1" ]; then
            print_status "Release SHA-1:   $RELEASE_SHA1"
            RELEASE_FINGERPRINTS+=("$RELEASE_SHA1")
            echo "$RELEASE_SHA1" > release_sha1.txt
        else
            print_error "Could not extract release SHA-1"
        fi
        
        if [ -n "$RELEASE_SHA256" ]; then
            print_info "Release SHA-256: $RELEASE_SHA256"
        fi
        
        if [ -n "$RELEASE_MD5" ]; then
            print_info "Release MD5:     $RELEASE_MD5"
        fi
    else
        print_error "Could not access release keystore. Please check password and alias."
    fi
else
    print_error "Release keystore not found at $RELEASE_KEYSTORE"
    print_info "Expected location: android/app/ehliyet-rehberim-key.jks"
fi

echo ""
echo "3. Analyzing Firebase Configuration..."
print_header "Firebase google-services.json Analysis"

GOOGLE_SERVICES="android/app/google-services.json"
if [ -f "$GOOGLE_SERVICES" ]; then
    print_status "google-services.json found"
    
    # Extract OAuth client information
    echo "OAuth Clients in Firebase configuration:"
    
    # Use jq if available, otherwise use grep
    if command -v jq &> /dev/null; then
        # Extract client IDs and their associated certificate hashes
        jq -r '.client[] | select(.oauth_client != null) | .oauth_client[] | select(.android_info != null) | "Client ID: " + .client_id + " | SHA-1: " + .android_info.certificate_hash' "$GOOGLE_SERVICES" 2>/dev/null | while read -r line; do
            print_info "$line"
            # Extract SHA-1 from the line
            SHA1=$(echo "$line" | grep -o '[A-F0-9:]\{59\}')
            if [ -n "$SHA1" ]; then
                FIREBASE_FINGERPRINTS+=("$SHA1")
            fi
        done
    else
        # Fallback to grep method
        print_info "Using grep method (install jq for better parsing)"
        grep -o '"certificate_hash": *"[^"]*"' "$GOOGLE_SERVICES" | cut -d'"' -f4 | while read -r hash; do
            print_info "Firebase SHA-1: $hash"
            FIREBASE_FINGERPRINTS+=("$hash")
        done
    fi
    
    # Check package name
    PACKAGE_NAME=$(grep -o '"package_name": *"[^"]*"' "$GOOGLE_SERVICES" | head -1 | cut -d'"' -f4)
    print_info "Package name: $PACKAGE_NAME"
    
    if [ "$PACKAGE_NAME" = "com.ehliyetrehberim.app" ]; then
        print_status "Package name is correct"
    else
        print_error "Package name mismatch. Expected: com.ehliyetrehberim.app, Found: $PACKAGE_NAME"
    fi
else
    print_error "google-services.json not found at $GOOGLE_SERVICES"
fi

echo ""
echo "4. Cross-Validation of SHA-1 Fingerprints..."
print_header "SHA-1 Cross-Validation"

# Function to check if SHA-1 exists in Firebase config
check_sha1_in_firebase() {
    local sha1="$1"
    local type="$2"
    
    if [ -f "$GOOGLE_SERVICES" ]; then
        if grep -q "$sha1" "$GOOGLE_SERVICES"; then
            print_status "$type SHA-1 found in Firebase configuration"
            return 0
        else
            print_error "$type SHA-1 NOT found in Firebase configuration"
            return 1
        fi
    else
        print_warning "Cannot validate - google-services.json not found"
        return 1
    fi
}

VALIDATION_PASSED=true

# Validate debug SHA-1
if [ -n "$DEBUG_SHA1" ]; then
    if ! check_sha1_in_firebase "$DEBUG_SHA1" "Debug"; then
        VALIDATION_PASSED=false
    fi
fi

# Validate release SHA-1
if [ -n "$RELEASE_SHA1" ]; then
    if ! check_sha1_in_firebase "$RELEASE_SHA1" "Release"; then
        VALIDATION_PASSED=false
    fi
fi

echo ""
echo "5. Play Store SHA-1 Information..."
print_header "Play Store App Signing"

print_info "For Play Store builds, Google may use App Signing which generates a different SHA-1."
print_info "To get the Play Store SHA-1:"
print_info "1. Go to Google Play Console"
print_info "2. Select your app"
print_info "3. Go to Release > Setup > App signing"
print_info "4. Copy the SHA-1 certificate fingerprint from 'App signing key certificate'"
print_info "5. Add this SHA-1 to Firebase Console"

echo ""
echo "6. Generating SHA-1 Report..."
print_header "SHA-1 Fingerprint Report"

# Create a comprehensive report
REPORT_FILE="sha1_fingerprint_report.txt"
{
    echo "SHA-1 Fingerprint Report"
    echo "Generated on: $(date)"
    echo "========================"
    echo ""
    
    echo "Debug Build:"
    echo "- SHA-1: ${DEBUG_SHA1:-'Not found'}"
    echo "- SHA-256: ${DEBUG_SHA256:-'Not found'}"
    echo "- MD5: ${DEBUG_MD5:-'Not found'}"
    echo ""
    
    echo "Release Build:"
    echo "- SHA-1: ${RELEASE_SHA1:-'Not found'}"
    echo "- SHA-256: ${RELEASE_SHA256:-'Not found'}"
    echo "- MD5: ${RELEASE_MD5:-'Not found'}"
    echo ""
    
    echo "Firebase Configuration:"
    if [ -f "$GOOGLE_SERVICES" ]; then
        echo "- Package Name: $PACKAGE_NAME"
        echo "- SHA-1 Fingerprints in config:"
        grep -o '"certificate_hash": *"[^"]*"' "$GOOGLE_SERVICES" | cut -d'"' -f4 | sed 's/^/  - /'
    else
        echo "- google-services.json not found"
    fi
    echo ""
    
    echo "Validation Results:"
    if [ -n "$DEBUG_SHA1" ]; then
        if grep -q "$DEBUG_SHA1" "$GOOGLE_SERVICES" 2>/dev/null; then
            echo "- Debug SHA-1: ✓ Found in Firebase"
        else
            echo "- Debug SHA-1: ✗ NOT found in Firebase"
        fi
    fi
    
    if [ -n "$RELEASE_SHA1" ]; then
        if grep -q "$RELEASE_SHA1" "$GOOGLE_SERVICES" 2>/dev/null; then
            echo "- Release SHA-1: ✓ Found in Firebase"
        else
            echo "- Release SHA-1: ✗ NOT found in Firebase"
        fi
    fi
    
} > "$REPORT_FILE"

print_status "Report saved to: $REPORT_FILE"

echo ""
echo "7. Validation Summary:"
print_header "Final Validation Results"

if [ "$VALIDATION_PASSED" = true ]; then
    print_status "SHA-1 validation passed!"
    echo ""
    echo "✅ All required SHA-1 fingerprints are properly configured in Firebase."
    echo "Google Sign-In should work correctly in both debug and release builds."
else
    print_error "SHA-1 validation failed!"
    echo ""
    echo "❌ Some SHA-1 fingerprints are missing from Firebase configuration."
    echo ""
    echo "🔧 To fix this:"
    echo "1. Go to Firebase Console > Project Settings > Your Apps"
    echo "2. Select your Android app"
    echo "3. Add the missing SHA certificate fingerprints:"
    
    if [ -n "$DEBUG_SHA1" ] && ! grep -q "$DEBUG_SHA1" "$GOOGLE_SERVICES" 2>/dev/null; then
        echo "   - Debug SHA-1: $DEBUG_SHA1"
    fi
    
    if [ -n "$RELEASE_SHA1" ] && ! grep -q "$RELEASE_SHA1" "$GOOGLE_SERVICES" 2>/dev/null; then
        echo "   - Release SHA-1: $RELEASE_SHA1"
    fi
    
    echo "4. Download the updated google-services.json"
    echo "5. Replace android/app/google-services.json with the new file"
    echo "6. Clean and rebuild your app"
fi

echo ""
print_info "For Play Store builds, also ensure the Play Store SHA-1 is added to Firebase."
print_info "This can be found in Google Play Console > App Signing section."

if [ "$VALIDATION_PASSED" = true ]; then
    exit 0
else
    exit 1
fi