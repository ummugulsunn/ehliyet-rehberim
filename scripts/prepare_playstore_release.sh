#!/bin/bash

# Play Store Internal Testing Preparation Script
# Prepares release APK for Play Store Internal Testing upload

set -e

echo "🏪 Play Store Internal Testing Preparation"
echo "=========================================="

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

# Create release directory if it doesn't exist
RELEASE_DIR="build/playstore_release"
mkdir -p "$RELEASE_DIR"

echo "1. Validating environment for Play Store release..."

# Check Flutter environment
flutter doctor --verbose

# Validate keystore
KEYSTORE_PATH="android/app/ehliyet-rehberim-key.jks"
if [ ! -f "$KEYSTORE_PATH" ]; then
    print_error "Release keystore not found at $KEYSTORE_PATH"
    exit 1
fi
print_status "Release keystore validated"

# Validate Firebase configuration
if [ ! -f "android/app/google-services.json" ]; then
    print_error "google-services.json not found"
    exit 1
fi
print_status "Firebase configuration validated"

echo ""
echo "2. Extracting SHA-1 fingerprints..."

# Extract release SHA-1
echo "Please enter the keystore password when prompted:"
RELEASE_SHA1=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias key 2>/dev/null | grep "SHA1:" | cut -d' ' -f3)

if [ -n "$RELEASE_SHA1" ]; then
    print_status "Release SHA-1: $RELEASE_SHA1"
    echo "$RELEASE_SHA1" > "$RELEASE_DIR/release_sha1.txt"
else
    print_error "Could not extract release SHA-1"
    exit 1
fi

echo ""
echo "3. Building release APK for Play Store..."

# Clean previous builds
flutter clean
flutter pub get

# Run critical tests before building
print_info "Running critical tests..."
flutter test test/core/services/auth_service_test.dart

# Build release APK
print_info "Building release APK (this may take several minutes)..."
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    print_error "Release APK not found after build"
    exit 1
fi

# Create timestamped release APK
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
PLAYSTORE_APK="$RELEASE_DIR/ehliyet-rehberim-playstore-$TIMESTAMP.apk"
cp "$APK_PATH" "$PLAYSTORE_APK"

APK_SIZE=$(du -h "$PLAYSTORE_APK" | cut -f1)
print_status "Play Store APK created: $PLAYSTORE_APK"
print_status "APK size: $APK_SIZE"

echo ""
echo "4. Generating release notes..."

# Create release notes template
RELEASE_NOTES="$RELEASE_DIR/release_notes_$TIMESTAMP.txt"
cat > "$RELEASE_NOTES" << EOF
Ehliyet Rehberim - Internal Testing Release $(date +"%Y-%m-%d")

🔧 Google Sign-In Improvements:
- Enhanced error handling for authentication failures
- Improved network connectivity checks
- Added fallback authentication options
- Better user experience during sign-in process

🧪 Testing Focus Areas:
- Google Sign-In functionality on various devices
- Network connectivity scenarios
- Fallback authentication methods
- App stability and performance

📱 Device Compatibility:
- Android 5.0+ (API level 21+)
- ARM and ARM64 architectures
- Various screen sizes and densities

🔍 Known Issues:
- None currently identified

📋 Test Instructions:
1. Install the app from Play Store Internal Testing
2. Test Google Sign-In with your Google account
3. Try signing in with poor network conditions
4. Test fallback authentication options if Google Sign-In fails
5. Report any issues through the feedback mechanism

Build Information:
- Build Date: $(date)
- APK Size: $APK_SIZE
- Version Code: $(grep "versionCode" android/app/build.gradle.kts | head -1 | grep -o '[0-9]*' || echo "Auto-generated")
- SHA-1 Fingerprint: $RELEASE_SHA1
EOF

print_status "Release notes created: $RELEASE_NOTES"

echo ""
echo "5. Creating Play Store upload checklist..."

CHECKLIST="$RELEASE_DIR/playstore_upload_checklist_$TIMESTAMP.md"
cat > "$CHECKLIST" << EOF
# Play Store Internal Testing Upload Checklist

## Pre-Upload Verification
- [ ] Release APK built successfully: \`$PLAYSTORE_APK\`
- [ ] APK size is reasonable: $APK_SIZE
- [ ] Release SHA-1 added to Firebase Console: \`$RELEASE_SHA1\`
- [ ] google-services.json updated with release SHA-1
- [ ] Critical tests passed
- [ ] App signed with release keystore

## Play Console Upload Steps

### 1. Access Play Console
- [ ] Go to [Google Play Console](https://play.google.com/console)
- [ ] Select "Ehliyet Rehberim" app
- [ ] Navigate to "Testing" > "Internal testing"

### 2. Create New Release
- [ ] Click "Create new release"
- [ ] Upload APK: \`$PLAYSTORE_APK\`
- [ ] Verify APK details (version code, size, etc.)

### 3. Release Notes
- [ ] Copy release notes from: \`$RELEASE_NOTES\`
- [ ] Customize for target audience if needed
- [ ] Ensure notes are in Turkish for Turkish users

### 4. Review and Rollout
- [ ] Review all details
- [ ] Click "Review release"
- [ ] Click "Start rollout to Internal testing"

## Post-Upload Configuration

### 1. Test User Management
- [ ] Go to "Testing" > "Internal testing" > "Testers"
- [ ] Add test users by email:
  - [ ] Development team members
  - [ ] QA team members
  - [ ] Selected beta users
- [ ] Send testing invitation links

### 2. Testing Track Configuration
- [ ] Verify internal testing track is active
- [ ] Check that testers can access the app
- [ ] Confirm download links work

## Test Scenarios Preparation

### 1. Google Sign-In Testing
- [ ] Test with multiple Google accounts
- [ ] Test on different Android versions
- [ ] Test with various network conditions
- [ ] Test fallback authentication methods

### 2. Device Testing
- [ ] Test on phones with different screen sizes
- [ ] Test on tablets
- [ ] Test on devices with different Android versions
- [ ] Test on devices with different RAM/storage

### 3. Network Testing
- [ ] Test with WiFi connection
- [ ] Test with mobile data
- [ ] Test with poor network conditions
- [ ] Test offline behavior

## Monitoring and Feedback

### 1. Crash Reporting
- [ ] Monitor Firebase Crashlytics for crashes
- [ ] Check Play Console for ANRs and crashes
- [ ] Review user feedback and ratings

### 2. Performance Monitoring
- [ ] Monitor app startup time
- [ ] Check memory usage
- [ ] Monitor network requests

### 3. User Feedback Collection
- [ ] Set up feedback collection mechanism
- [ ] Monitor user reviews in Play Console
- [ ] Track authentication success rates

## Success Criteria
- [ ] All test users can download and install the app
- [ ] Google Sign-In works for all test users
- [ ] No critical crashes reported
- [ ] App performance is acceptable
- [ ] User feedback is positive

## Next Steps After Internal Testing
- [ ] Address any issues found during internal testing
- [ ] Prepare for closed testing with larger user group
- [ ] Plan for open testing phase
- [ ] Prepare for production release

---
Generated on: $(date)
APK: $PLAYSTORE_APK
SHA-1: $RELEASE_SHA1
EOF

print_status "Upload checklist created: $CHECKLIST"

echo ""
echo "6. Creating test scenarios document..."

TEST_SCENARIOS="$RELEASE_DIR/test_scenarios_$TIMESTAMP.md"
cat > "$TEST_SCENARIOS" << EOF
# Internal Testing Scenarios for Ehliyet Rehberim

## Overview
This document outlines comprehensive test scenarios for the Google Sign-In Play Store fix during internal testing phase.

## Test Environment Setup
- **Testing Track**: Play Store Internal Testing
- **Target Devices**: Android 5.0+ devices
- **Test Duration**: 1-2 weeks
- **Test Users**: 10-20 internal testers

## Primary Test Scenarios

### Scenario 1: Google Sign-In Success Flow
**Objective**: Verify Google Sign-In works correctly in Play Store environment

**Prerequisites**:
- Fresh app installation from Play Store Internal Testing
- Valid Google account
- Internet connection available

**Test Steps**:
1. Launch the app
2. Navigate to authentication screen
3. Tap "Google ile Giriş" button
4. Select Google account from picker
5. Grant necessary permissions
6. Verify successful authentication

**Expected Results**:
- Google account picker appears
- Authentication completes successfully
- User is logged in and can access app features
- User profile information is displayed correctly

**Test Data**:
- Use different Google accounts (personal, work, etc.)
- Test with accounts that have 2FA enabled
- Test with accounts that have app-specific passwords

---

### Scenario 2: Network Connectivity Issues
**Objective**: Verify app behavior with poor or no network connectivity

**Prerequisites**:
- App installed from Play Store Internal Testing
- Ability to control network connectivity

**Test Steps**:
1. Launch app with no internet connection
2. Attempt Google Sign-In
3. Verify error handling
4. Enable internet connection
5. Retry Google Sign-In
6. Test with poor network conditions (slow 3G)

**Expected Results**:
- Appropriate error message shown for no connectivity
- Retry mechanism works when connectivity restored
- App doesn't crash with network issues
- Loading indicators shown during network operations

---

### Scenario 3: Fallback Authentication Methods
**Objective**: Test fallback options when Google Sign-In fails

**Prerequisites**:
- App installed from Play Store Internal Testing
- Simulated Google Sign-In failure

**Test Steps**:
1. Launch app
2. Attempt Google Sign-In (simulate failure)
3. Verify fallback options are presented
4. Test Apple Sign-In (iOS only)
5. Test Guest Mode option
6. Verify limited functionality in Guest Mode

**Expected Results**:
- Fallback dialog appears on Google Sign-In failure
- Apple Sign-In works on iOS devices
- Guest Mode allows basic app usage
- Clear indication of limited features in Guest Mode

---

### Scenario 4: Authentication State Management
**Objective**: Verify authentication state is properly managed

**Prerequisites**:
- App installed from Play Store Internal Testing
- User authenticated with Google

**Test Steps**:
1. Sign in with Google account
2. Close app completely
3. Reopen app
4. Verify authentication state persisted
5. Sign out from app
6. Verify sign-out completed
7. Test app restart after sign-out

**Expected Results**:
- Authentication state persists across app restarts
- User remains signed in after app closure
- Sign-out clears authentication state
- App shows login screen after sign-out

---

### Scenario 5: Multiple Device Testing
**Objective**: Verify app works across different Android devices

**Test Devices**:
- Samsung Galaxy (various models)
- Google Pixel devices
- OnePlus devices
- Xiaomi devices
- Huawei devices (if available)

**Test Steps**:
1. Install app on each device type
2. Test Google Sign-In on each device
3. Verify UI rendering on different screen sizes
4. Test performance on different hardware specs
5. Verify app behavior on different Android versions

**Expected Results**:
- App installs successfully on all devices
- Google Sign-In works on all devices
- UI adapts properly to different screen sizes
- Performance is acceptable on all devices

---

### Scenario 6: Error Recovery Testing
**Objective**: Test app's ability to recover from various error conditions

**Test Steps**:
1. Test with expired Google tokens
2. Test with revoked app permissions
3. Test with account that doesn't exist
4. Test with disabled Google account
5. Test with network timeouts
6. Test with server errors

**Expected Results**:
- Appropriate error messages for each condition
- App doesn't crash on any error
- Recovery mechanisms work properly
- User can retry after errors

---

### Scenario 7: Performance and Stability
**Objective**: Verify app performance and stability

**Test Steps**:
1. Monitor app startup time
2. Test memory usage during extended use
3. Test with multiple sign-in/sign-out cycles
4. Monitor for memory leaks
5. Test app behavior under low memory conditions
6. Verify no ANRs (Application Not Responding)

**Expected Results**:
- App starts within acceptable time (< 3 seconds)
- Memory usage remains stable
- No memory leaks detected
- App responds to user interactions promptly
- No ANRs or crashes

---

## Secondary Test Scenarios

### Scenario 8: Edge Cases
- Test with very long Google account names
- Test with special characters in account names
- Test with accounts that have profile pictures
- Test with accounts without profile pictures
- Test rapid sign-in/sign-out cycles

### Scenario 9: Accessibility Testing
- Test with TalkBack enabled
- Test with large font sizes
- Test with high contrast mode
- Verify all buttons are accessible
- Test keyboard navigation

### Scenario 10: Localization Testing
- Test with Turkish language settings
- Test with English language settings
- Verify all error messages are localized
- Test with right-to-left languages (if supported)

## Test Reporting

### Success Criteria
- [ ] Google Sign-In success rate > 95%
- [ ] No critical crashes
- [ ] App startup time < 3 seconds
- [ ] All fallback mechanisms work
- [ ] User feedback is positive

### Failure Criteria
- Google Sign-In fails consistently
- App crashes during authentication
- Performance is unacceptable
- Critical features don't work
- Negative user feedback

### Reporting Template
For each test scenario, report:
- **Test Date**: 
- **Device**: 
- **Android Version**: 
- **Test Result**: Pass/Fail
- **Issues Found**: 
- **Screenshots**: (if applicable)
- **Additional Notes**: 

## Test Schedule

### Week 1: Core Functionality
- Days 1-3: Google Sign-In testing
- Days 4-5: Fallback mechanism testing
- Days 6-7: Error handling testing

### Week 2: Extended Testing
- Days 1-2: Performance testing
- Days 3-4: Multi-device testing
- Days 5-7: Edge cases and final validation

## Contact Information
- **Test Coordinator**: [Name]
- **Development Team**: [Contact]
- **Issue Reporting**: [Method]

---
Generated on: $(date)
For Internal Testing Release: $TIMESTAMP
EOF

print_status "Test scenarios created: $TEST_SCENARIOS"

echo ""
echo "7. Creating test user invitation template..."

INVITATION_TEMPLATE="$RELEASE_DIR/test_user_invitation_template.md"
cat > "$INVITATION_TEMPLATE" << EOF
# Internal Testing Invitation - Ehliyet Rehberim

## Merhaba [Test User Name],

Ehliyet Rehberim uygulamasının yeni versiyonunu test etmeniz için sizi davet ediyoruz. Bu versiyon özellikle Google Sign-In özelliğindeki iyileştirmeleri içermektedir.

## Test Süreci

### 1. Uygulamayı İndirin
- Play Store Internal Testing linkini kullanarak uygulamayı indirin
- Link: [Play Store Internal Testing Link - Will be provided after upload]

### 2. Test Edilecek Özellikler
- **Google ile Giriş**: Ana odak noktamız
- **Ağ bağlantısı sorunları**: Zayıf internet durumlarında davranış
- **Alternatif giriş yöntemleri**: Google Sign-In başarısız olduğunda
- **Genel uygulama kararlılığı**: Çökme ve performans sorunları

### 3. Test Senaryoları

#### Temel Test
1. Uygulamayı açın
2. "Google ile Giriş" butonuna tıklayın
3. Google hesabınızı seçin
4. Giriş işleminin başarılı olduğunu doğrulayın

#### Ağ Testi
1. WiFi/mobil veriyi kapatın
2. Google Sign-In'i deneyin
3. Hata mesajını kontrol edin
4. İnterneti açın ve tekrar deneyin

#### Alternatif Giriş Testi
1. Google Sign-In başarısız olursa
2. Sunulan alternatif seçenekleri test edin
3. "Misafir Modu" seçeneğini deneyin

### 4. Geri Bildirim

Lütfen aşağıdaki bilgileri paylaşın:

**Cihaz Bilgileri**:
- Cihaz modeli: 
- Android versiyonu: 
- RAM miktarı: 

**Test Sonuçları**:
- Google Sign-In çalıştı mı? (Evet/Hayır)
- Herhangi bir hata mesajı gördünüz mü?
- Uygulama çöktü mü?
- Performans nasıldı? (Hızlı/Normal/Yavaş)

**Sorunlar**:
- Karşılaştığınız sorunları detaylı açıklayın
- Mümkünse ekran görüntüsü alın
- Sorunun tekrarlanabilir olup olmadığını belirtin

### 5. Geri Bildirim Kanalları
- **Email**: [email address]
- **WhatsApp**: [phone number]
- **Telegram**: [username]

### 6. Test Süresi
- **Başlangıç**: [Start Date]
- **Bitiş**: [End Date]
- **Süre**: 1-2 hafta

## Önemli Notlar

- Bu bir test versiyonudur, küçük hatalar olabilir
- Kişisel verileriniz güvende, test amaçlı kullanılmaktadır
- Geri bildirimleriniz uygulamanın geliştirilmesi için çok değerlidir
- Sorularınız için yukarıdaki iletişim kanallarını kullanabilirsiniz

## Teşekkürler

Zamanınızı ayırıp uygulamayı test ettiğiniz için teşekkür ederiz. Geri bildirimleriniz sayesinde daha iyi bir uygulama sunabileceğiz.

---
Ehliyet Rehberim Geliştirme Ekibi
$(date)
EOF

print_status "Invitation template created: $INVITATION_TEMPLATE"

echo ""
echo "8. Generating final summary..."

SUMMARY="$RELEASE_DIR/playstore_preparation_summary_$TIMESTAMP.md"
cat > "$SUMMARY" << EOF
# Play Store Internal Testing Preparation Summary

**Preparation Date**: $(date)
**Release APK**: $PLAYSTORE_APK
**APK Size**: $APK_SIZE
**SHA-1 Fingerprint**: $RELEASE_SHA1

## Generated Files

1. **Release APK**: \`$PLAYSTORE_APK\`
   - Ready for Play Store upload
   - Signed with release keystore
   - Size: $APK_SIZE

2. **Release Notes**: \`$RELEASE_NOTES\`
   - Turkish and English versions
   - Focus on Google Sign-In improvements
   - Testing instructions included

3. **Upload Checklist**: \`$CHECKLIST\`
   - Step-by-step upload guide
   - Pre and post-upload tasks
   - Success criteria defined

4. **Test Scenarios**: \`$TEST_SCENARIOS\`
   - Comprehensive testing scenarios
   - Primary and secondary test cases
   - Performance and stability tests

5. **Invitation Template**: \`$INVITATION_TEMPLATE\`
   - Ready-to-send invitation for testers
   - Turkish language template
   - Clear testing instructions

## Next Steps

### Immediate Actions
1. Upload APK to Play Console Internal Testing
2. Configure internal testing track
3. Add test users (10-20 recommended)
4. Send invitations to test users

### During Testing Period
1. Monitor crash reports and feedback
2. Track authentication success rates
3. Collect performance metrics
4. Address critical issues promptly

### Post-Testing Actions
1. Analyze test results
2. Fix identified issues
3. Prepare for closed testing phase
4. Plan production release

## Key Metrics to Track

- **Google Sign-In Success Rate**: Target > 95%
- **App Crash Rate**: Target < 0.1%
- **User Satisfaction**: Target > 4.0/5.0
- **Performance**: Startup time < 3 seconds

## Contact Information

- **Development Team**: [Contact Info]
- **QA Team**: [Contact Info]
- **Project Manager**: [Contact Info]

## Files Location
All generated files are in: \`$RELEASE_DIR/\`

---
Generated by: prepare_playstore_release.sh
EOF

print_status "Preparation summary created: $SUMMARY"

echo ""
echo "🎉 Play Store Internal Testing Preparation Complete!"
echo "=================================================="

print_status "Release APK ready: $PLAYSTORE_APK"
print_status "All documentation generated in: $RELEASE_DIR/"

echo ""
echo "📋 Next Steps:"
echo "1. Review the upload checklist: $CHECKLIST"
echo "2. Upload APK to Play Console Internal Testing"
echo "3. Configure test users and send invitations"
echo "4. Monitor testing progress and feedback"

echo ""
echo "📁 Generated Files:"
echo "- Release APK: $PLAYSTORE_APK"
echo "- Release Notes: $RELEASE_NOTES"
echo "- Upload Checklist: $CHECKLIST"
echo "- Test Scenarios: $TEST_SCENARIOS"
echo "- Invitation Template: $INVITATION_TEMPLATE"
echo "- Summary: $SUMMARY"

echo ""
print_info "All files are ready for Play Store Internal Testing!"