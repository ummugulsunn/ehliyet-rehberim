#!/bin/bash

# Firebase Configuration Validation Script
# This script validates the current Firebase configuration for Google Sign-In

echo "🔍 Firebase Configuration Validation"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validation results
VALIDATION_PASSED=true

# Function to check if file exists and is readable
check_file() {
    local file_path=$1
    local description=$2
    
    if [ -f "$file_path" ]; then
        echo -e "${GREEN}✅ $description found: $file_path${NC}"
        return 0
    else
        echo -e "${RED}❌ $description missing: $file_path${NC}"
        VALIDATION_PASSED=false
        return 1
    fi
}

# Function to validate JSON file
validate_json() {
    local file_path=$1
    local description=$2
    
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool "$file_path" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $description is valid JSON${NC}"
            return 0
        else
            echo -e "${RED}❌ $description is invalid JSON${NC}"
            VALIDATION_PASSED=false
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  Cannot validate JSON (python3 not available)${NC}"
        return 0
    fi
}

echo -e "${BLUE}1. Configuration Files Check${NC}"
echo "----------------------------"

# Check Android configuration
check_file "android/app/google-services.json" "Android google-services.json"
if [ $? -eq 0 ]; then
    validate_json "android/app/google-services.json" "google-services.json"
fi

# Check iOS configuration  
check_file "ios/Runner/GoogleService-Info.plist" "iOS GoogleService-Info.plist"

# Check keystore files
check_file "android/app/ehliyet-rehberim-key.jks" "Release keystore"
check_file "android/key.properties" "Keystore properties"

echo ""

echo -e "${BLUE}2. Package Name Validation${NC}"
echo "-------------------------"

# Check Android package name
if [ -f "android/app/build.gradle.kts" ]; then
    ANDROID_PACKAGE=$(grep -o 'applicationId = "[^"]*"' android/app/build.gradle.kts | sed 's/applicationId = "//' | sed 's/"//')
    if [ "$ANDROID_PACKAGE" = "com.ehliyetrehberim.app" ]; then
        echo -e "${GREEN}✅ Android package name: $ANDROID_PACKAGE${NC}"
    else
        echo -e "${RED}❌ Android package name mismatch: $ANDROID_PACKAGE (expected: com.ehliyetrehberim.app)${NC}"
        VALIDATION_PASSED=false
    fi
else
    echo -e "${RED}❌ Android build.gradle.kts not found${NC}"
    VALIDATION_PASSED=false
fi

# Check iOS bundle ID
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    IOS_BUNDLE=$(grep -A 1 "<key>BUNDLE_ID</key>" ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>//' | sed 's/<\/string>.*//')
    if [ "$IOS_BUNDLE" = "com.turkmenapps.ehliyetrehberim" ]; then
        echo -e "${GREEN}✅ iOS bundle ID: $IOS_BUNDLE${NC}"
    else
        echo -e "${RED}❌ iOS bundle ID mismatch: $IOS_BUNDLE (expected: com.turkmenapps.ehliyetrehberim)${NC}"
        VALIDATION_PASSED=false
    fi
fi

echo ""

echo -e "${BLUE}3. SHA-1 Fingerprint Analysis${NC}"
echo "-----------------------------"

# Extract and display current SHA-1s
if [ -f "android/app/google-services.json" ]; then
    echo -e "${YELLOW}Current SHA-1s in Firebase:${NC}"
    grep -o '"certificate_hash": "[^"]*"' android/app/google-services.json | sed 's/"certificate_hash": "/  /' | sed 's/"//'
    
    # Count SHA-1s
    SHA1_COUNT=$(grep -c '"certificate_hash"' android/app/google-services.json)
    echo -e "${BLUE}Total SHA-1 fingerprints configured: $SHA1_COUNT${NC}"
    
    if [ $SHA1_COUNT -lt 2 ]; then
        echo -e "${YELLOW}⚠️  Consider adding more SHA-1 fingerprints (debug, release, Play Store)${NC}"
    fi
fi

echo ""

echo -e "${BLUE}4. OAuth Client Configuration${NC}"
echo "----------------------------"

if [ -f "android/app/google-services.json" ]; then
    # Count OAuth clients
    OAUTH_COUNT=$(grep -c '"client_type": 1' android/app/google-services.json)
    echo -e "${BLUE}Android OAuth clients configured: $OAUTH_COUNT${NC}"
    
    # Check for web client
    WEB_CLIENT_COUNT=$(grep -c '"client_type": 3' android/app/google-services.json)
    echo -e "${BLUE}Web OAuth clients configured: $WEB_CLIENT_COUNT${NC}"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    IOS_CLIENT_ID=$(grep -A 1 "<key>CLIENT_ID</key>" ios/Runner/GoogleService-Info.plist | grep "<string>" | sed 's/.*<string>//' | sed 's/<\/string>.*//')
    if [ ! -z "$IOS_CLIENT_ID" ]; then
        echo -e "${GREEN}✅ iOS Client ID configured: ${IOS_CLIENT_ID:0:20}...${NC}"
    else
        echo -e "${RED}❌ iOS Client ID not found${NC}"
        VALIDATION_PASSED=false
    fi
fi

echo ""

echo -e "${BLUE}5. Project Configuration${NC}"
echo "----------------------"

# Check Firebase project ID
if [ -f "android/app/google-services.json" ]; then
    PROJECT_ID=$(grep -o '"project_id": "[^"]*"' android/app/google-services.json | sed 's/"project_id": "//' | sed 's/"//')
    if [ "$PROJECT_ID" = "ehliyet-rehberim" ]; then
        echo -e "${GREEN}✅ Firebase project ID: $PROJECT_ID${NC}"
    else
        echo -e "${RED}❌ Firebase project ID mismatch: $PROJECT_ID (expected: ehliyet-rehberim)${NC}"
        VALIDATION_PASSED=false
    fi
fi

echo ""

echo -e "${BLUE}6. Recommendations${NC}"
echo "-----------------"

# Check if release SHA-1 matches
RELEASE_SHA1=$(keytool -list -v -keystore android/app/ehliyet-rehberim-key.jks -alias ehliyet-rehberim -storepass ehliyet123 -keypass ehliyet123 2>/dev/null | grep SHA1 | sed 's/.*SHA1: //' | tr -d ' \n' | tr '[:upper:]' '[:lower:]')

if [ -f "android/app/google-services.json" ] && [ ! -z "$RELEASE_SHA1" ]; then
    if grep -q "$RELEASE_SHA1" android/app/google-services.json; then
        echo -e "${GREEN}✅ Release keystore SHA-1 is configured in Firebase${NC}"
    else
        echo -e "${YELLOW}⚠️  Release keystore SHA-1 not found in Firebase configuration${NC}"
        echo -e "${YELLOW}   Add this SHA-1 to Firebase: $RELEASE_SHA1${NC}"
    fi
fi

echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Obtain Play Store App Signing SHA-1 from Play Console"
echo "2. Add missing SHA-1 fingerprints to Firebase Console"
echo "3. Download updated configuration files"
echo "4. Test Google Sign-In functionality"

echo ""

# Final validation result
if [ "$VALIDATION_PASSED" = true ]; then
    echo -e "${GREEN}✅ Configuration validation passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Configuration validation failed. Please fix the issues above.${NC}"
    exit 1
fi