#!/bin/bash

# Google Sign-In Integration Tests Runner
# This script runs all integration tests for the Google Sign-In Play Store fix

set -e

echo "🚀 Starting Google Sign-In Integration Tests"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Navigate to project directory
cd "$(dirname "$0")/.."

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Are you in the correct directory?"
    exit 1
fi

# Install dependencies
print_status "Installing dependencies..."
flutter pub get

# Check if integration test directory exists
if [ ! -d "integration_test" ]; then
    print_error "integration_test directory not found"
    exit 1
fi

# Function to run a specific test file
run_test() {
    local test_file=$1
    local test_name=$2
    
    print_status "Running $test_name..."
    
    if flutter test "$test_file" --verbose; then
        print_success "$test_name completed successfully"
        return 0
    else
        print_error "$test_name failed"
        return 1
    fi
}

# Initialize test results
total_tests=0
passed_tests=0
failed_tests=0

# Test files and their descriptions
declare -A tests=(
    ["integration_test/auth_flow_integration_test.dart"]="Auth Flow Integration Tests"
    ["integration_test/fallback_mechanism_integration_test.dart"]="Fallback Mechanism Tests"
    ["integration_test/ui_interaction_integration_test.dart"]="UI Interaction Tests"
    ["integration_test/end_to_end_auth_flow_test.dart"]="End-to-End Auth Flow Tests"
)

# Check if specific test is requested
if [ $# -eq 1 ]; then
    test_arg=$1
    case $test_arg in
        "auth")
            tests=(["integration_test/auth_flow_integration_test.dart"]="Auth Flow Integration Tests")
            ;;
        "fallback")
            tests=(["integration_test/fallback_mechanism_integration_test.dart"]="Fallback Mechanism Tests")
            ;;
        "ui")
            tests=(["integration_test/ui_interaction_integration_test.dart"]="UI Interaction Tests")
            ;;
        "e2e")
            tests=(["integration_test/end_to_end_auth_flow_test.dart"]="End-to-End Auth Flow Tests")
            ;;
        "all")
            # Keep all tests (default behavior)
            ;;
        *)
            print_error "Unknown test type: $test_arg"
            echo "Available options: auth, fallback, ui, e2e, all"
            exit 1
            ;;
    esac
fi

# Run each test
for test_file in "${!tests[@]}"; do
    test_name="${tests[$test_file]}"
    total_tests=$((total_tests + 1))
    
    if [ -f "$test_file" ]; then
        if run_test "$test_file" "$test_name"; then
            passed_tests=$((passed_tests + 1))
        else
            failed_tests=$((failed_tests + 1))
        fi
    else
        print_warning "Test file not found: $test_file"
        failed_tests=$((failed_tests + 1))
    fi
    
    echo ""
done

# Print summary
echo "============================================="
echo "🏁 Integration Test Summary"
echo "============================================="
echo "Total Tests: $total_tests"
print_success "Passed: $passed_tests"
if [ $failed_tests -gt 0 ]; then
    print_error "Failed: $failed_tests"
else
    echo "Failed: $failed_tests"
fi

# Exit with appropriate code
if [ $failed_tests -eq 0 ]; then
    print_success "All integration tests passed! 🎉"
    exit 0
else
    print_error "Some integration tests failed. Please check the output above."
    exit 1
fi