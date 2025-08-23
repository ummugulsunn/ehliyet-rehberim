# Build Test Scripts

This directory contains comprehensive scripts for testing debug and release builds, with special focus on Google Sign-In functionality and SHA-1 fingerprint validation.

## Scripts Overview

### 1. `run_build_tests.sh` - Main Test Runner
**Purpose**: Runs all build tests in sequence and generates comprehensive reports.

**Usage**:
```bash
./scripts/run_build_tests.sh
```

**What it does**:
- Runs SHA-1 fingerprint validation
- Validates local release build configuration
- Tests debug build creation and functionality
- Tests release build creation and functionality
- Validates Firebase configuration
- Generates comprehensive test reports and logs

### 2. `validate_sha1_fingerprints.sh` - SHA-1 Validation
**Purpose**: Extracts and validates SHA-1 fingerprints for debug and release keystores.

**Usage**:
```bash
./scripts/validate_sha1_fingerprints.sh
```

**What it does**:
- Extracts SHA-1 from debug keystore (`~/.android/debug.keystore`)
- Extracts SHA-1 from release keystore (`android/app/ehliyet-rehberim-key.jks`)
- Validates SHA-1 fingerprints against Firebase configuration
- Generates SHA-1 fingerprint report
- Provides instructions for Play Store SHA-1 setup

**Output Files**:
- `debug_sha1.txt` - Debug SHA-1 fingerprint
- `release_sha1.txt` - Release SHA-1 fingerprint
- `sha1_fingerprint_report.txt` - Comprehensive SHA-1 report

### 3. `validate_local_release.sh` - Release Configuration Validation
**Purpose**: Validates local release build configuration before building.

**Usage**:
```bash
./scripts/validate_local_release.sh
```

**What it does**:
- Validates Flutter project structure
- Checks keystore and key.properties configuration
- Validates Firebase configuration files
- Checks build.gradle configuration
- Validates required dependencies
- Tests keystore access
- Validates Flutter environment

### 4. `test_debug_build.sh` - Debug Build Testing
**Purpose**: Creates and tests debug APK with Google Sign-In functionality.

**Usage**:
```bash
./scripts/test_debug_build.sh
```

**What it does**:
- Extracts debug SHA-1 fingerprint
- Validates Firebase configuration for debug build
- Runs unit tests
- Builds debug APK
- Installs APK on connected device (if available)
- Runs integration tests
- Provides manual testing checklist

**Output**:
- Debug APK at `build/app/outputs/flutter-apk/app-debug.apk`
- Debug SHA-1 in `debug_sha1.txt`

### 5. `test_release_build.sh` - Release Build Testing
**Purpose**: Creates and tests release APK with Google Sign-In functionality.

**Usage**:
```bash
./scripts/test_release_build.sh
```

**What it does**:
- Extracts release SHA-1 fingerprint
- Validates Firebase configuration for release build
- Runs pre-build tests
- Builds release APK
- Analyzes APK contents and signature
- Installs APK on connected device (if available)
- Provides manual testing checklist

**Output**:
- Release APK at `build/app/outputs/flutter-apk/app-release.apk`
- Timestamped backup APK
- Release SHA-1 in `release_sha1.txt`

## Prerequisites

### Required Tools
- Flutter SDK
- Android SDK with build tools
- Java keytool (usually included with JDK)
- ADB (Android Debug Bridge) - optional, for device testing

### Required Files
- `android/app/ehliyet-rehberim-key.jks` - Release keystore
- `android/key.properties` - Keystore configuration
- `android/app/google-services.json` - Firebase Android configuration
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS configuration

### Environment Setup
1. Ensure Flutter is properly installed and configured
2. Accept Android licenses: `flutter doctor --android-licenses`
3. Connect an Android device or start an emulator (optional, for device testing)

## Usage Workflow

### Quick Start
Run all tests with a single command:
```bash
./scripts/run_build_tests.sh
```

### Step-by-Step Testing
1. **Validate SHA-1 fingerprints**:
   ```bash
   ./scripts/validate_sha1_fingerprints.sh
   ```

2. **Validate release configuration**:
   ```bash
   ./scripts/validate_local_release.sh
   ```

3. **Test debug build**:
   ```bash
   ./scripts/test_debug_build.sh
   ```

4. **Test release build**:
   ```bash
   ./scripts/test_release_build.sh
   ```

## Output and Logs

### Log Files
All scripts generate detailed logs in the `logs/` directory:
- `sha1_validation_TIMESTAMP.log`
- `local_release_validation_TIMESTAMP.log`
- `debug_build_test_TIMESTAMP.log`
- `release_build_test_TIMESTAMP.log`
- `build_test_report_TIMESTAMP.txt` - Comprehensive test report

### Artifacts
- `debug_sha1.txt` - Debug SHA-1 fingerprint
- `release_sha1.txt` - Release SHA-1 fingerprint
- `sha1_fingerprint_report.txt` - SHA-1 analysis report
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Common Issues

#### 1. SHA-1 Not Found in Firebase
**Problem**: Script reports SHA-1 fingerprint not found in Firebase configuration.

**Solution**:
1. Go to Firebase Console > Project Settings > Your Apps
2. Select your Android app
3. Add the SHA certificate fingerprint
4. Download updated `google-services.json`
5. Replace `android/app/google-services.json`

#### 2. Keystore Access Issues
**Problem**: Cannot access release keystore.

**Solution**:
1. Verify keystore file exists at `android/app/ehliyet-rehberim-key.jks`
2. Check `android/key.properties` configuration
3. Ensure correct password and alias name

#### 3. Build Failures
**Problem**: APK build fails.

**Solution**:
1. Run `flutter doctor` to check environment
2. Run `flutter clean` and `flutter pub get`
3. Check build.gradle configuration
4. Verify all dependencies are compatible

#### 4. Google Sign-In Fails
**Problem**: Google Sign-In doesn't work in built APK.

**Solution**:
1. Verify SHA-1 fingerprint is added to Firebase Console
2. Ensure `google-services.json` is updated
3. Check internet connection on test device
4. Verify Google Play Services is installed on device

### Getting Help

If you encounter issues:
1. Check the generated log files in `logs/` directory
2. Review the comprehensive test report
3. Follow the troubleshooting steps in script output
4. Ensure all prerequisites are met

## Manual Testing Checklist

After running the scripts, manually test:

### Debug Build
- [ ] Install debug APK on test device
- [ ] Open app and navigate to authentication
- [ ] Test Google Sign-In functionality
- [ ] Verify successful authentication
- [ ] Test sign-out functionality

### Release Build
- [ ] Install release APK on test device
- [ ] Open app and navigate to authentication
- [ ] Test Google Sign-In functionality
- [ ] Verify successful authentication with Google account
- [ ] Test sign-out functionality
- [ ] Test app functionality with authenticated user
- [ ] Verify no debug-specific features are present

### Play Store Testing
- [ ] Upload release APK to Play Store Internal Testing
- [ ] Install from Play Store Internal Testing
- [ ] Test Google Sign-In in Play Store environment
- [ ] Verify all functionality works correctly

## Integration with CI/CD

These scripts can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions integration
- name: Run Build Tests
  run: |
    chmod +x scripts/run_build_tests.sh
    ./scripts/run_build_tests.sh

- name: Upload Test Reports
  uses: actions/upload-artifact@v3
  with:
    name: build-test-reports
    path: logs/
```

## Security Notes

- Keystore files and passwords should be kept secure
- Never commit keystore files or passwords to version control
- Use environment variables or secure storage for sensitive data
- SHA-1 fingerprints are not sensitive and can be shared publicly

## Contributing

When modifying these scripts:
1. Maintain backward compatibility
2. Update this README with any changes
3. Test scripts on different environments
4. Follow existing error handling patterns
5. Update the test file `test/scripts/build_test_scripts_test.dart`