#!/bin/bash

# SHA-1 Fingerprint Extraction Script for Google Sign-In Configuration
# This script extracts SHA-1 fingerprints from debug and release keystores

echo "🔐 SHA-1 Fingerprint Extraction for Google Sign-In"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to extract SHA-1 and format it
extract_sha1() {
    local keystore_path=$1
    local alias=$2
    local store_pass=$3
    local key_pass=$4
    local description=$5
    
    echo -e "${BLUE}Extracting SHA-1 for $description...${NC}"
    
    if [ -f "$keystore_path" ]; then
        sha1=$(keytool -list -v -keystore "$keystore_path" -alias "$alias" -storepass "$store_pass" -keypass "$key_pass" 2>/dev/null | grep SHA1 | sed 's/.*SHA1: //' | tr -d ' \n')
        if [ ! -z "$sha1" ]; then
            echo -e "${GREEN}✅ $description SHA-1:${NC}"
            echo -e "${GREEN}   $sha1${NC}"
            echo -e "${GREEN}   (lowercase: $(echo $sha1 | tr '[:upper:]' '[:lower:]'))${NC}"
        else
            echo -e "${RED}❌ Failed to extract SHA-1 from $description${NC}"
        fi
    else
        echo -e "${RED}❌ Keystore not found: $keystore_path${NC}"
    fi
    echo ""
}

# Extract Debug SHA-1
echo -e "${YELLOW}1. Debug Keystore${NC}"
extract_sha1 "$HOME/.android/debug.keystore" "androiddebugkey" "android" "android" "Debug"

# Extract Release SHA-1
echo -e "${YELLOW}2. Release Keystore${NC}"
if [ -f "android/app/ehliyet-rehberim-key.jks" ]; then
    extract_sha1 "android/app/ehliyet-rehberim-key.jks" "ehliyet-rehberim" "ehliyet123" "ehliyet123" "Release"
else
    echo -e "${RED}❌ Release keystore not found at android/app/ehliyet-rehberim-key.jks${NC}"
    echo ""
fi

# Instructions for Play Store SHA-1
echo -e "${YELLOW}3. Play Store App Signing SHA-1${NC}"
echo -e "${BLUE}To get the Play Store App Signing SHA-1:${NC}"
echo "1. Go to Google Play Console"
echo "2. Select your app: Ehliyet Rehberim"
echo "3. Navigate to: Setup > App signing"
echo "4. Copy the SHA-1 certificate fingerprint from 'App signing key certificate'"
echo ""

# Current Firebase Configuration Analysis
echo -e "${YELLOW}4. Current Firebase Configuration Analysis${NC}"
if [ -f "android/app/google-services.json" ]; then
    echo -e "${BLUE}Analyzing current google-services.json...${NC}"
    
    # Extract SHA-1s from google-services.json
    sha1_hashes=$(grep -o '"certificate_hash": "[^"]*"' android/app/google-services.json | sed 's/"certificate_hash": "//' | sed 's/"//')
    
    echo -e "${GREEN}SHA-1 hashes currently in Firebase:${NC}"
    while IFS= read -r hash; do
        if [ ! -z "$hash" ]; then
            echo "   $hash"
        fi
    done <<< "$sha1_hashes"
else
    echo -e "${RED}❌ google-services.json not found${NC}"
fi
echo ""

# Next Steps
echo -e "${YELLOW}5. Next Steps${NC}"
echo "1. Compare the extracted SHA-1s with those in Firebase Console"
echo "2. Add any missing SHA-1s to Firebase Console"
echo "3. Download updated google-services.json and GoogleService-Info.plist"
echo "4. Replace the configuration files in your project"
echo "5. Test Google Sign-In functionality"
echo ""

echo -e "${GREEN}✅ SHA-1 extraction complete!${NC}"
echo -e "${BLUE}📋 Check docs/sha1_fingerprint_analysis.md for detailed analysis${NC}"