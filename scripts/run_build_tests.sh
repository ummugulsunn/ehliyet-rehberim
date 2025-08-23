#!/bin/bash

# Comprehensive Build Test Runner
# Runs all debug and release build tests with SHA-1 validation

set -e

echo "🧪 Comprehensive Build Test Suite"
echo "=================================="

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
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Function to run a test script and track results
run_test() {
    local script_name="$1"
    local description="$2"
    
    print_header "$description"
    
    if [ -f "$script_name" ]; then
        # Make script executable
        chmod +x "$script_name"
        
        # Run the script and capture exit code
        if "$script_name"; then
            print_status "$description completed successfully"
            ((TESTS_PASSED++))
            return 0
        else
            print_error "$description failed"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        print_error "Test script not found: $script_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to run a test script that may have warnings
run_test_with_warnings() {
    local script_name="$1"
    local description="$2"
    
    print_header "$description"
    
    if [ -f "$script_name" ]; then
        # Make script executable
        chmod +x "$script_name"
        
        # Run the script and capture exit code
        if "$script_name"; then
            print_status "$description completed successfully"
            ((TESTS_PASSED++))
            return 0
        else
            print_warning "$description completed with warnings"
            ((TESTS_WARNINGS++))
            return 1
        fi
    else
        print_error "Test script not found: $script_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check if we're in the Flutter project directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project directory. Please run from project root."
    exit 1
fi

# Create logs directory
mkdir -p logs

# Get current timestamp for log files
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "Starting comprehensive build test suite..."
echo "Logs will be saved to logs/ directory"
echo ""

# Test 1: SHA-1 Fingerprint Validation
echo "Test 1/5: SHA-1 Fingerprint Validation"
if run_test "scripts/validate_sha1_fingerprints.sh" "SHA-1 Fingerprint Validation" 2>&1 | tee "logs/sha1_validation_$TIMESTAMP.log"; then
    echo ""
else
    print_warning "SHA-1 validation issues detected. Check logs/sha1_validation_$TIMESTAMP.log"
    echo ""
fi

# Test 2: Local Release Build Validation
echo "Test 2/5: Local Release Build Validation"
if run_test "scripts/validate_local_release.sh" "Local Release Build Validation" 2>&1 | tee "logs/local_release_validation_$TIMESTAMP.log"; then
    echo ""
else
    print_warning "Local release validation issues detected. Check logs/local_release_validation_$TIMESTAMP.log"
    echo ""
fi

# Test 3: Debug Build Test
echo "Test 3/5: Debug Build Test"
if run_test_with_warnings "scripts/test_debug_build.sh" "Debug Build Test" 2>&1 | tee "logs/debug_build_test_$TIMESTAMP.log"; then
    echo ""
else
    print_warning "Debug build test completed with warnings. Check logs/debug_build_test_$TIMESTAMP.log"
    echo ""
fi

# Test 4: Release Build Test
echo "Test 4/5: Release Build Test"
if run_test_with_warnings "scripts/test_release_build.sh" "Release Build Test" 2>&1 | tee "logs/release_build_test_$TIMESTAMP.log"; then
    echo ""
else
    print_warning "Release build test completed with warnings. Check logs/release_build_test_$TIMESTAMP.log"
    echo ""
fi

# Test 5: Firebase Configuration Validation
echo "Test 5/5: Firebase Configuration Validation"
if [ -f "scripts/validate_firebase_config.sh" ]; then
    if run_test "scripts/validate_firebase_config.sh" "Firebase Configuration Validation" 2>&1 | tee "logs/firebase_validation_$TIMESTAMP.log"; then
        echo ""
    else
        print_warning "Firebase validation issues detected. Check logs/firebase_validation_$TIMESTAMP.log"
        echo ""
    fi
else
    print_info "Firebase validation script not found, skipping..."
    echo ""
fi

# Generate comprehensive test report
print_header "Test Suite Summary"

REPORT_FILE="logs/build_test_report_$TIMESTAMP.txt"
{
    echo "Build Test Suite Report"
    echo "======================="
    echo "Generated on: $(date)"
    echo "Timestamp: $TIMESTAMP"
    echo ""
    
    echo "Test Results:"
    echo "- Tests Passed: $TESTS_PASSED"
    echo "- Tests Failed: $TESTS_FAILED"
    echo "- Tests with Warnings: $TESTS_WARNINGS"
    echo "- Total Tests: $((TESTS_PASSED + TESTS_FAILED + TESTS_WARNINGS))"
    echo ""
    
    echo "Log Files Generated:"
    echo "- SHA-1 Validation: logs/sha1_validation_$TIMESTAMP.log"
    echo "- Local Release Validation: logs/local_release_validation_$TIMESTAMP.log"
    echo "- Debug Build Test: logs/debug_build_test_$TIMESTAMP.log"
    echo "- Release Build Test: logs/release_build_test_$TIMESTAMP.log"
    if [ -f "logs/firebase_validation_$TIMESTAMP.log" ]; then
        echo "- Firebase Validation: logs/firebase_validation_$TIMESTAMP.log"
    fi
    echo ""
    
    echo "Artifacts Generated:"
    if [ -f "debug_sha1.txt" ]; then
        echo "- Debug SHA-1: $(cat debug_sha1.txt)"
    fi
    if [ -f "release_sha1.txt" ]; then
        echo "- Release SHA-1: $(cat release_sha1.txt)"
    fi
    if [ -f "sha1_fingerprint_report.txt" ]; then
        echo "- SHA-1 Report: sha1_fingerprint_report.txt"
    fi
    
    # Check for built APKs
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        DEBUG_SIZE=$(du -h "build/app/outputs/flutter-apk/app-debug.apk" | cut -f1)
        echo "- Debug APK: build/app/outputs/flutter-apk/app-debug.apk ($DEBUG_SIZE)"
    fi
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        RELEASE_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        echo "- Release APK: build/app/outputs/flutter-apk/app-release.apk ($RELEASE_SIZE)"
    fi
    
} > "$REPORT_FILE"

print_status "Comprehensive test report saved to: $REPORT_FILE"

echo ""
echo "📊 Test Results Summary:"
echo "========================"
echo "✅ Tests Passed: $TESTS_PASSED"
echo "❌ Tests Failed: $TESTS_FAILED"
echo "⚠️  Tests with Warnings: $TESTS_WARNINGS"
echo "📁 Total Tests: $((TESTS_PASSED + TESTS_FAILED + TESTS_WARNINGS))"

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    if [ $TESTS_WARNINGS -eq 0 ]; then
        print_status "🎉 All tests passed successfully!"
        echo ""
        echo "✅ Your build configuration is ready for:"
        echo "- Debug builds with Google Sign-In"
        echo "- Release builds with Google Sign-In"
        echo "- Play Store deployment"
        echo ""
        echo "📋 Next Steps:"
        echo "1. Test Google Sign-In manually on debug build"
        echo "2. Test Google Sign-In manually on release build"
        echo "3. Upload release APK to Play Store Internal Testing"
        echo "4. Test Google Sign-In in Play Store environment"
    else
        print_warning "🎯 Tests completed with warnings!"
        echo ""
        echo "⚠️  Some tests completed with warnings. Review the logs for details."
        echo "Most issues are likely related to missing devices or optional configurations."
        echo ""
        echo "📋 Recommended Actions:"
        echo "1. Review warning messages in log files"
        echo "2. Test manually on physical devices"
        echo "3. Verify Google Sign-In functionality"
    fi
else
    print_error "❌ Some tests failed!"
    echo ""
    echo "🔧 Please fix the following before proceeding:"
    echo "- Review failed test logs in logs/ directory"
    echo "- Fix configuration issues identified"
    echo "- Re-run the test suite after fixes"
    echo ""
    echo "Common issues:"
    echo "- Missing or incorrect keystore configuration"
    echo "- SHA-1 fingerprints not added to Firebase Console"
    echo "- Outdated google-services.json file"
    echo "- Missing dependencies or Flutter environment issues"
fi

echo ""
print_info "📁 All logs and reports are available in the logs/ directory"
print_info "🔍 For detailed information, check the individual log files"

# Exit with appropriate code
if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi