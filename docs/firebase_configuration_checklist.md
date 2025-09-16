# Firebase Configuration Checklist for Google Sign-In

## 🎯 Objective
Configure Firebase Console with all necessary SHA-1 fingerprints to enable Google Sign-In in Play Store builds.

## 📋 Pre-Configuration Analysis

### Current Status
- ✅ Debug SHA-1: `7a75d0b5a026b72af52225335c8875418b0a4ad7` (Already in Firebase)
- ❌ Release SHA-1: `a3:5d:bf:79:cb:f5:16:2d:75:f7:6b:56:dd:57:f4:e9:d2:d7:4e:01` (Missing from Firebase)
- ❓ Play Store SHA-1: Unknown (Need to obtain from Play Console)

### Current Firebase SHA-1s
1. `7a75d0b5a026b72af52225335c8875418b0a4ad7` (Debug - Correct ✅)
2. `a46f40fbebc31162fbf645b200c74df06a266bb1` (Unknown source - Needs verification ❓)

## 🔧 Configuration Steps

### Step 1: Obtain Play Store App Signing SHA-1
1. Go to [Google Play Console](https://play.google.com/console)
2. Select "Ehliyet Rehberim" app
3. Navigate to: **Setup** → **App signing**
4. Find "App signing key certificate" section
5. Copy the **SHA-1 certificate fingerprint**
6. ✅ **Play Store SHA-1**: `8f:e0:2a:6e:b3:8a:06:e3:e9:8f:5d:a7:28:b5:a0:11:9d:e9:aa:e4`

### Step 2: Update Firebase Console - Android App
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **ehliyet-rehberim**
3. Navigate to: **Project Settings** → **Your apps** → **Android app**
4. Click on the Android app (com.ehliyetrehberim.app)
5. Scroll down to **SHA certificate fingerprints**

#### Add Missing SHA-1 Fingerprints:
- [ ] **Release SHA-1**: `a35dbf79cbf5162d75f76b56dd57f4e9d2d74e01`
- [ ] **Play Store SHA-1**: `8fe02a6eb38a06e3e98f5da728b5a0119de9aae4`

#### Verify Existing SHA-1 Fingerprints:
- [ ] **Debug SHA-1**: `7a75d0b5a026b72af52225335c8875418b0a4ad7` ✅
- [ ] **Unknown SHA-1**: `a46f40fbebc31162fbf645b200c74df06a266bb1` (Verify or remove)

### Step 3: Download Updated Configuration Files
1. After adding SHA-1 fingerprints, download updated files:
   - [ ] **google-services.json** (Android)
   - [ ] **GoogleService-Info.plist** (iOS - if any changes)

### Step 4: Update Project Configuration Files
1. Replace `android/app/google-services.json` with the new file
2. Replace `ios/Runner/GoogleService-Info.plist` if updated
3. Commit changes to version control

### Step 5: Verify Configuration
1. Check that new SHA-1s are present in the updated google-services.json:
   ```bash
   grep -o '"certificate_hash": "[^"]*"' android/app/google-services.json
   ```

## 🧪 Testing Checklist

### Local Testing
- [ ] **Debug Build**: Test Google Sign-In in debug mode
- [ ] **Release Build**: Create and test local release APK
  ```bash
  flutter build apk --release
  # Install and test the APK
  ```

### Play Store Testing
- [ ] **Upload to Play Console**: Upload release APK to Internal Testing
- [ ] **Internal Testing**: Test Google Sign-In with Play Store build
- [ ] **Multiple Devices**: Test on different Android devices
- [ ] **Network Conditions**: Test with different network conditions

## 🔍 Troubleshooting

### Common Issues
1. **"Sign in failed"**: Check if all SHA-1s are correctly added to Firebase
2. **"Developer Error"**: Verify package name matches in Firebase and build.gradle
3. **"Network Error"**: Check internet connection and Firebase project status

### Debug Commands
```bash
# Extract current SHA-1s from keystore
./scripts/extract_sha1.sh

# Check current Firebase configuration
grep -A 10 -B 2 "certificate_hash" android/app/google-services.json

# Verify package name
grep "applicationId" android/app/build.gradle.kts
```

## 📝 Documentation

### Record Configuration Details
- **Date Configured**: `_____________`
- **Firebase Project ID**: `ehliyet-rehberim`
- **Android Package Name**: `com.ehliyetrehberim.app`
- **iOS Bundle ID**: `com.turkmenapps.ehliyetrehberim`
- **Play Store SHA-1**: `8fe02a6eb38a06e3e98f5da728b5a0119de9aae4`
- **Configured By**: `_____________`

### Files Updated
- [ ] `android/app/google-services.json`
- [ ] `ios/Runner/GoogleService-Info.plist` (if needed)
- [ ] `docs/sha1_fingerprint_analysis.md`

## ✅ Completion Criteria

This task is complete when:
1. All SHA-1 fingerprints (debug, release, Play Store) are added to Firebase Console
2. Updated google-services.json and GoogleService-Info.plist are downloaded and integrated
3. Google Sign-In works in debug, release, and Play Store builds
4. Configuration is documented and verified

## 🚀 Next Steps

After completing this configuration:
1. Proceed to Task 2: AuthService Hata Yönetimi Geliştirmeleri
2. Implement comprehensive error handling for authentication failures
3. Add fallback mechanisms for sign-in issues