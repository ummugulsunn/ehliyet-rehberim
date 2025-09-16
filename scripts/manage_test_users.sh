#!/bin/bash

# Test User Management Script for Play Store Internal Testing
# Helps manage test user lists and invitations

set -e

echo "👥 Test User Management for Internal Testing"
echo "============================================"

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

# Create test users directory
TEST_USERS_DIR="build/test_users"
mkdir -p "$TEST_USERS_DIR"

# Function to show menu
show_menu() {
    echo ""
    echo "Select an option:"
    echo "1. Create test user list"
    echo "2. Generate invitation emails"
    echo "3. Create test scenarios for users"
    echo "4. Generate feedback collection template"
    echo "5. Create user tracking spreadsheet"
    echo "6. Exit"
    echo ""
}

# Function to create test user list
create_test_user_list() {
    echo ""
    echo "📝 Creating Test User List"
    echo "========================="
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    USER_LIST="$TEST_USERS_DIR/test_users_$TIMESTAMP.txt"
    
    echo "# Ehliyet Rehberim Internal Testing - Test Users List" > "$USER_LIST"
    echo "# Generated on: $(date)" >> "$USER_LIST"
    echo "# " >> "$USER_LIST"
    echo "# Instructions:" >> "$USER_LIST"
    echo "# - Add one email address per line" >> "$USER_LIST"
    echo "# - Use the same Google account for Play Store and testing" >> "$USER_LIST"
    echo "# - Ensure users have Android devices with Play Store access" >> "$USER_LIST"
    echo "# " >> "$USER_LIST"
    echo "" >> "$USER_LIST"
    echo "# Development Team" >> "$USER_LIST"
    echo "developer1@example.com" >> "$USER_LIST"
    echo "developer2@example.com" >> "$USER_LIST"
    echo "qa.lead@example.com" >> "$USER_LIST"
    echo "" >> "$USER_LIST"
    echo "# QA Team" >> "$USER_LIST"
    echo "qa.tester1@example.com" >> "$USER_LIST"
    echo "qa.tester2@example.com" >> "$USER_LIST"
    echo "qa.tester3@example.com" >> "$USER_LIST"
    echo "" >> "$USER_LIST"
    echo "# Product Team" >> "$USER_LIST"
    echo "product.manager@example.com" >> "$USER_LIST"
    echo "ux.designer@example.com" >> "$USER_LIST"
    echo "" >> "$USER_LIST"
    echo "# Beta Users" >> "$USER_LIST"
    echo "beta.user1@gmail.com" >> "$USER_LIST"
    echo "beta.user2@gmail.com" >> "$USER_LIST"
    echo "beta.user3@gmail.com" >> "$USER_LIST"
    echo "beta.user4@gmail.com" >> "$USER_LIST"
    echo "beta.user5@gmail.com" >> "$USER_LIST"
    echo "" >> "$USER_LIST"
    echo "# Device Variety Testers" >> "$USER_LIST"
    echo "samsung.tester@gmail.com" >> "$USER_LIST"
    echo "pixel.tester@gmail.com" >> "$USER_LIST"
    echo "oneplus.tester@gmail.com" >> "$USER_LIST"
    echo "xiaomi.tester@gmail.com" >> "$USER_LIST"
    
    print_status "Test user list created: $USER_LIST"
    print_info "Please edit this file and replace example emails with real test user emails"
    
    echo ""
    echo "📋 Recommended Test User Categories:"
    echo "- Development Team (3-5 users): Core developers and QA leads"
    echo "- QA Team (3-5 users): Professional testers with various devices"
    echo "- Product Team (2-3 users): Product managers and designers"
    echo "- Beta Users (5-10 users): Enthusiastic users willing to test"
    echo "- Device Variety (3-5 users): Users with different device brands"
    echo ""
    echo "Total recommended: 16-28 users (start with 10-15 for internal testing)"
}

# Function to generate invitation emails
generate_invitation_emails() {
    echo ""
    echo "📧 Generating Invitation Email Templates"
    echo "======================================="
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    
    # Turkish invitation
    TURKISH_INVITATION="$TEST_USERS_DIR/invitation_turkish_$TIMESTAMP.md"
    cat > "$TURKISH_INVITATION" << 'EOF'
# Ehliyet Rehberim - Internal Testing Daveti

Merhaba [TESTER_NAME],

Ehliyet Rehberim uygulamasının yeni versiyonunu test etmeniz için sizi davet ediyoruz! 🚗📱

## 🎯 Test Amacı
Bu versiyon özellikle **Google ile Giriş** özelliğindeki iyileştirmeleri içermektedir. Sizin değerli geri bildirimleriniz sayesinde uygulamayı daha da iyi hale getirmek istiyoruz.

## 📲 Nasıl Katılabilirsiniz?

### 1. Adım: Test Programına Katılın
- Bu linke tıklayın: [INTERNAL_TESTING_LINK]
- Google hesabınızla giriş yapın (Android cihazınızda kullandığınız hesap)
- "Tester ol" butonuna tıklayın

### 2. Adım: Uygulamayı İndirin
- Play Store'dan "Ehliyet Rehberim" uygulamasını arayın
- "Internal testing" versiyonunu indirin
- Uygulamayı yükleyin

### 3. Adım: Test Edin
Lütfen aşağıdaki senaryoları test edin:

#### ✅ Temel Test
1. Uygulamayı açın
2. "Google ile Giriş" butonuna tıklayın
3. Google hesabınızı seçin
4. Giriş işleminin başarılı olduğunu kontrol edin

#### ✅ Ağ Bağlantısı Testi
1. WiFi/mobil veriyi kapatın
2. Google Sign-In'i deneyin
3. Hata mesajını kontrol edin
4. İnterneti açıp tekrar deneyin

#### ✅ Alternatif Giriş Testi
1. Google Sign-In başarısız olursa
2. Sunulan alternatif seçenekleri test edin
3. "Misafir Modu" seçeneğini deneyin

## 📝 Geri Bildirim

### Cihaz Bilgileriniz:
- **Cihaz Modeli**: 
- **Android Versiyonu**: 
- **RAM Miktarı**: 

### Test Sonuçları:
- **Google Sign-In çalıştı mı?**: Evet / Hayır
- **Herhangi bir hata gördünüz mü?**: 
- **Uygulama çöktü mü?**: Evet / Hayır
- **Performans nasıldı?**: Hızlı / Normal / Yavaş

### Sorunlar:
Karşılaştığınız sorunları detaylı açıklayın:
- 
- 
- 

## 📞 İletişim
- **Email**: [CONTACT_EMAIL]
- **WhatsApp**: [CONTACT_PHONE]
- **Telegram**: [CONTACT_TELEGRAM]

## ⏰ Test Süresi
- **Başlangıç**: [START_DATE]
- **Bitiş**: [END_DATE]
- **Süre**: 1-2 hafta

## 🙏 Teşekkürler
Zamanınızı ayırıp uygulamayı test ettiğiniz için çok teşekkür ederiz. Geri bildirimleriniz bizim için çok değerli!

---
Ehliyet Rehberim Geliştirme Ekibi
[DATE]
EOF

    # English invitation
    ENGLISH_INVITATION="$TEST_USERS_DIR/invitation_english_$TIMESTAMP.md"
    cat > "$ENGLISH_INVITATION" << 'EOF'
# Ehliyet Rehberim - Internal Testing Invitation

Hello [TESTER_NAME],

We invite you to test the new version of the Ehliyet Rehberim app! 🚗📱

## 🎯 Testing Purpose
This version specifically includes improvements to the **Google Sign-In** feature. We want to make the app even better with your valuable feedback.

## 📲 How to Join?

### Step 1: Join Testing Program
- Click this link: [INTERNAL_TESTING_LINK]
- Sign in with your Google account (the one you use on your Android device)
- Click "Become a tester"

### Step 2: Download the App
- Search for "Ehliyet Rehberim" in Play Store
- Download the "Internal testing" version
- Install the app

### Step 3: Test
Please test the following scenarios:

#### ✅ Basic Test
1. Open the app
2. Tap "Google ile Giriş" (Sign in with Google)
3. Select your Google account
4. Verify successful sign-in

#### ✅ Network Connectivity Test
1. Turn off WiFi/mobile data
2. Try Google Sign-In
3. Check error message
4. Turn internet back on and retry

#### ✅ Fallback Authentication Test
1. If Google Sign-In fails
2. Test alternative options presented
3. Try "Guest Mode" option

## 📝 Feedback

### Your Device Info:
- **Device Model**: 
- **Android Version**: 
- **RAM Amount**: 

### Test Results:
- **Did Google Sign-In work?**: Yes / No
- **Did you see any errors?**: 
- **Did the app crash?**: Yes / No
- **How was performance?**: Fast / Normal / Slow

### Issues:
Please describe any issues you encountered:
- 
- 
- 

## 📞 Contact
- **Email**: [CONTACT_EMAIL]
- **WhatsApp**: [CONTACT_PHONE]
- **Telegram**: [CONTACT_TELEGRAM]

## ⏰ Testing Period
- **Start**: [START_DATE]
- **End**: [END_DATE]
- **Duration**: 1-2 weeks

## 🙏 Thank You
Thank you very much for taking the time to test our app. Your feedback is invaluable to us!

---
Ehliyet Rehberim Development Team
[DATE]
EOF

    print_status "Turkish invitation template created: $TURKISH_INVITATION"
    print_status "English invitation template created: $ENGLISH_INVITATION"
    
    echo ""
    echo "📝 To customize the invitations:"
    echo "1. Replace [TESTER_NAME] with actual tester names"
    echo "2. Replace [INTERNAL_TESTING_LINK] with actual Play Store testing link"
    echo "3. Replace [CONTACT_EMAIL], [CONTACT_PHONE], [CONTACT_TELEGRAM] with real contact info"
    echo "4. Replace [START_DATE] and [END_DATE] with actual testing dates"
    echo "5. Replace [DATE] with current date"
}

# Function to create test scenarios for users
create_test_scenarios() {
    echo ""
    echo "📋 Creating User Test Scenarios"
    echo "=============================="
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    SCENARIOS="$TEST_USERS_DIR/user_test_scenarios_$TIMESTAMP.md"
    
    cat > "$SCENARIOS" << 'EOF'
# Ehliyet Rehberim - Test Senaryoları (Test Scenarios)

## 🎯 Ana Hedef (Main Goal)
Google ile Giriş özelliğinin Play Store ortamında düzgün çalıştığını doğrulamak.
(Verify that Google Sign-In works properly in Play Store environment)

## 📱 Test Öncesi Hazırlık (Pre-Test Preparation)

### Gereksinimler (Requirements):
- [ ] Android 5.0+ cihaz
- [ ] Google Play Store yüklü
- [ ] İnternet bağlantısı
- [ ] Google hesabı (Gmail)
- [ ] Test davetini kabul etmiş olmak

### Kurulum (Setup):
1. Play Store Internal Testing linkine tıklayın
2. "Tester ol" butonuna basın
3. Play Store'dan uygulamayı indirin
4. Uygulamayı yükleyin

## 🧪 Test Senaryoları (Test Scenarios)

### Senaryo 1: Başarılı Google Giriş (Successful Google Sign-In)
**Süre**: 2-3 dakika

**Adımlar**:
1. Uygulamayı açın
2. "Google ile Giriş" butonuna tıklayın
3. Google hesap seçicisinden hesabınızı seçin
4. Gerekli izinleri verin
5. Giriş işleminin tamamlanmasını bekleyin

**Beklenen Sonuç**:
- ✅ Google hesap seçicisi açılır
- ✅ Hesap seçimi başarılı olur
- ✅ İzin verme ekranı görünür
- ✅ Giriş başarıyla tamamlanır
- ✅ Ana ekrana yönlendirilirsiniz
- ✅ Profil bilgileriniz görünür

**Sorun Durumunda**:
- Ekran görüntüsü alın
- Hata mesajını not edin
- Cihaz ve Android versiyonunu belirtin

---

### Senaryo 2: Ağ Bağlantısı Sorunları (Network Issues)
**Süre**: 3-4 dakika

**Adımlar**:
1. WiFi ve mobil veriyi kapatın
2. Uygulamayı açın
3. "Google ile Giriş" butonuna tıklayın
4. Hata mesajını gözlemleyin
5. İnternet bağlantısını açın
6. Tekrar giriş yapmayı deneyin

**Beklenen Sonuç**:
- ✅ İnternet yokken uygun hata mesajı gösterilir
- ✅ "Bağlantı yok" veya benzeri mesaj görünür
- ✅ İnternet açıldığında tekrar deneme çalışır
- ✅ Giriş başarıyla tamamlanır

---

### Senaryo 3: Alternatif Giriş Seçenekleri (Fallback Options)
**Süre**: 2-3 dakika

**Adımlar**:
1. Google Sign-In'i deneyin
2. Eğer başarısız olursa, sunulan seçenekleri kontrol edin
3. "Misafir Modu" seçeneğini deneyin
4. Misafir modunda uygulama özelliklerini test edin

**Beklenen Sonuç**:
- ✅ Google Sign-In başarısız olursa alternatif seçenekler sunulur
- ✅ "Misafir Modu" seçeneği çalışır
- ✅ Misafir modunda temel özellikler kullanılabilir
- ✅ Sınırlı özellik uyarısı gösterilir

---

### Senaryo 4: Oturum Yönetimi (Session Management)
**Süre**: 3-4 dakika

**Adımlar**:
1. Google ile giriş yapın
2. Uygulamayı tamamen kapatın (recent apps'tan kaldırın)
3. Uygulamayı tekrar açın
4. Giriş durumunun korunduğunu kontrol edin
5. Çıkış yapın
6. Çıkış işleminin başarılı olduğunu kontrol edin

**Beklenen Sonuç**:
- ✅ Uygulama kapatılıp açıldığında giriş durumu korunur
- ✅ Kullanıcı bilgileri görünmeye devam eder
- ✅ Çıkış butonu çalışır
- ✅ Çıkış sonrası giriş ekranı gösterilir

---

### Senaryo 5: Performans Testi (Performance Test)
**Süre**: 5 dakika

**Adımlar**:
1. Uygulamayı açma süresini ölçün (yaklaşık)
2. Google Sign-In süresini ölçün
3. Uygulama içinde gezinirken performansı gözlemleyin
4. Bellek kullanımını gözlemleyin (Settings > Apps > Ehliyet Rehberim)
5. Birden fazla giriş-çıkış işlemi yapın

**Beklenen Sonuç**:
- ✅ Uygulama 3 saniyeden kısa sürede açılır
- ✅ Google Sign-In 5-10 saniyede tamamlanır
- ✅ Uygulama akıcı çalışır
- ✅ Bellek kullanımı makul seviyede kalır
- ✅ Çoklu giriş-çıkış işlemlerinde sorun olmaz

## 📊 Test Sonuçları Formu (Test Results Form)

### Cihaz Bilgileri (Device Information):
- **Marka/Model**: 
- **Android Versiyonu**: 
- **RAM**: 
- **Depolama**: 
- **Ekran Boyutu**: 

### Test Sonuçları (Test Results):

#### Senaryo 1 - Google Sign-In:
- [ ] Başarılı / [ ] Başarısız
- **Süre**: ___ saniye
- **Notlar**: 

#### Senaryo 2 - Ağ Sorunları:
- [ ] Başarılı / [ ] Başarısız
- **Hata Mesajı**: 
- **Notlar**: 

#### Senaryo 3 - Alternatif Seçenekler:
- [ ] Başarılı / [ ] Başarısız
- **Kullanılan Seçenek**: 
- **Notlar**: 

#### Senaryo 4 - Oturum Yönetimi:
- [ ] Başarılı / [ ] Başarısız
- **Notlar**: 

#### Senaryo 5 - Performans:
- [ ] Başarılı / [ ] Başarısız
- **Açılma Süresi**: ___ saniye
- **Sign-In Süresi**: ___ saniye
- **Notlar**: 

### Genel Değerlendirme (Overall Assessment):
- **Genel Memnuniyet**: ⭐⭐⭐⭐⭐ (1-5 yıldız)
- **En Beğendiğiniz Özellik**: 
- **En Çok Sorun Yaşadığınız Alan**: 
- **Öneriler**: 

### Karşılaşılan Sorunlar (Issues Encountered):
1. 
2. 
3. 

### Ekran Görüntüleri (Screenshots):
Lütfen sorunların ekran görüntülerini çekin ve paylaşın.

---

## 📞 Destek İletişim (Support Contact)
Herhangi bir sorun yaşarsanız:
- **Email**: [SUPPORT_EMAIL]
- **WhatsApp**: [SUPPORT_PHONE]
- **Test Süresi**: [TEST_PERIOD]

Testiniz için teşekkürler! 🙏
Thank you for your testing! 🙏
EOF

    print_status "User test scenarios created: $SCENARIOS"
    print_info "This document can be sent to testers as a comprehensive testing guide"
}

# Function to generate feedback collection template
generate_feedback_template() {
    echo ""
    echo "📝 Generating Feedback Collection Template"
    echo "========================================="
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    FEEDBACK_TEMPLATE="$TEST_USERS_DIR/feedback_collection_$TIMESTAMP.md"
    
    cat > "$FEEDBACK_TEMPLATE" << 'EOF'
# Ehliyet Rehberim - Internal Testing Feedback Collection

## Test Information
- **Tester Name**: 
- **Email**: 
- **Test Date**: 
- **Testing Duration**: 

## Device Information
- **Device Brand/Model**: 
- **Android Version**: 
- **RAM**: 
- **Storage Available**: 
- **Screen Size**: 
- **Network Type**: WiFi / Mobile Data / Both

## Installation Experience
- **Installation Successful**: Yes / No
- **Installation Time**: ___ minutes
- **Any Installation Issues**: 

## Google Sign-In Testing

### First Attempt
- **Result**: Success / Failed
- **Time Taken**: ___ seconds
- **Google Account Type**: Personal / Work / School
- **Error Message (if failed)**: 

### Network Conditions Test
- **Tested with No Internet**: Yes / No
- **Error Message Shown**: 
- **Recovery After Internet Restored**: Yes / No

### Multiple Attempts
- **Number of Sign-In Attempts**: 
- **Success Rate**: ___/___
- **Consistent Behavior**: Yes / No

## Fallback Authentication

### Guest Mode
- **Guest Mode Available**: Yes / No
- **Guest Mode Functional**: Yes / No
- **Feature Limitations Clear**: Yes / No

### Apple Sign-In (iOS only)
- **Available**: Yes / No / N/A
- **Functional**: Yes / No / N/A

## App Performance

### Startup Performance
- **App Launch Time**: ___ seconds
- **Responsive During Launch**: Yes / No
- **Any Lag or Freezing**: Yes / No

### Memory Usage
- **App Runs Smoothly**: Yes / No
- **Device Becomes Slow**: Yes / No
- **App Crashes**: Yes / No (How many times: ___)

### Battery Usage
- **Noticeable Battery Drain**: Yes / No
- **Device Gets Hot**: Yes / No

## User Experience

### Interface
- **UI is Clear and Intuitive**: Strongly Agree / Agree / Neutral / Disagree / Strongly Disagree
- **Error Messages are Helpful**: Strongly Agree / Agree / Neutral / Disagree / Strongly Disagree
- **Loading Indicators are Clear**: Strongly Agree / Agree / Neutral / Disagree / Strongly Disagree

### Authentication Flow
- **Sign-In Process is Smooth**: Strongly Agree / Agree / Neutral / Disagree / Strongly Disagree
- **Sign-Out Process Works Well**: Strongly Agree / Agree / Neutral / Disagree / Strongly Disagree
- **Session Management is Good**: Strongly Agree / Agree / Neutral / Disagree / Strongly Disagree

## Issues and Bugs

### Critical Issues (App Crashes, Can't Sign In)
1. 
2. 
3. 

### Minor Issues (UI Glitches, Slow Performance)
1. 
2. 
3. 

### Suggestions for Improvement
1. 
2. 
3. 

## Detailed Issue Reports

### Issue #1
- **Type**: Critical / Major / Minor / Cosmetic
- **Description**: 
- **Steps to Reproduce**: 
  1. 
  2. 
  3. 
- **Expected Behavior**: 
- **Actual Behavior**: 
- **Frequency**: Always / Often / Sometimes / Rarely
- **Screenshot Available**: Yes / No

### Issue #2
- **Type**: Critical / Major / Minor / Cosmetic
- **Description**: 
- **Steps to Reproduce**: 
  1. 
  2. 
  3. 
- **Expected Behavior**: 
- **Actual Behavior**: 
- **Frequency**: Always / Often / Sometimes / Rarely
- **Screenshot Available**: Yes / No

### Issue #3
- **Type**: Critical / Major / Minor / Cosmetic
- **Description**: 
- **Steps to Reproduce**: 
  1. 
  2. 
  3. 
- **Expected Behavior**: 
- **Actual Behavior**: 
- **Frequency**: Always / Often / Sometimes / Rarely
- **Screenshot Available**: Yes / No

## Overall Assessment

### Satisfaction Rating
- **Overall App Quality**: ⭐⭐⭐⭐⭐ (1-5 stars)
- **Google Sign-In Experience**: ⭐⭐⭐⭐⭐ (1-5 stars)
- **App Performance**: ⭐⭐⭐⭐⭐ (1-5 stars)
- **User Interface**: ⭐⭐⭐⭐⭐ (1-5 stars)

### Recommendation
- **Would you recommend this app**: Yes / No / Maybe
- **Ready for wider testing**: Yes / No / With fixes
- **Ready for production**: Yes / No / Needs more work

### Additional Comments
Please provide any additional feedback, suggestions, or comments:




## Testing Completion
- **All Test Scenarios Completed**: Yes / No
- **Total Testing Time**: ___ hours
- **Willing to Test Future Versions**: Yes / No

---

**Feedback Submitted By**: [Tester Name]
**Date**: [Date]
**Contact for Follow-up**: [Email/Phone]

Thank you for your detailed feedback! 🙏
EOF

    print_status "Feedback collection template created: $FEEDBACK_TEMPLATE"
    print_info "This template can be sent to testers for structured feedback collection"
}

# Function to create user tracking spreadsheet
create_tracking_spreadsheet() {
    echo ""
    echo "📊 Creating User Tracking Spreadsheet Template"
    echo "=============================================="
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    TRACKING_CSV="$TEST_USERS_DIR/user_tracking_$TIMESTAMP.csv"
    
    cat > "$TRACKING_CSV" << 'EOF'
Tester Name,Email,Invitation Sent,Invitation Date,Joined Testing,Join Date,App Installed,Install Date,Feedback Received,Feedback Date,Device Model,Android Version,Google Sign-In Status,Issues Reported,Overall Rating,Notes,Follow-up Required,Contact Method
John Doe,john.doe@example.com,Yes,2024-01-15,Yes,2024-01-16,Yes,2024-01-16,Yes,2024-01-18,Samsung Galaxy S21,Android 12,Success,None,5,Great experience,No,Email
Jane Smith,jane.smith@example.com,Yes,2024-01-15,Yes,2024-01-16,Yes,2024-01-16,No,,,Google Pixel 6,Android 13,Unknown,Unknown,Unknown,Waiting for feedback,Yes,WhatsApp
Developer A,dev.a@company.com,Yes,2024-01-15,Yes,2024-01-15,Yes,2024-01-15,Yes,2024-01-17,OnePlus 9,Android 11,Success,Minor UI issue,4,Good overall,No,Slack
QA Tester 1,qa1@company.com,Yes,2024-01-15,Yes,2024-01-15,Yes,2024-01-15,Yes,2024-01-16,Xiaomi Mi 11,Android 12,Failed,Google Sign-In error,2,Critical issue found,Yes,Email
Beta User 1,beta1@gmail.com,Yes,2024-01-15,No,,,,,,,,,,,Invitation not accepted,Yes,Email
EOF

    print_status "User tracking spreadsheet created: $TRACKING_CSV"
    
    # Create a more detailed tracking template
    DETAILED_TRACKING="$TEST_USERS_DIR/detailed_tracking_template_$TIMESTAMP.md"
    cat > "$DETAILED_TRACKING" << 'EOF'
# Internal Testing - Detailed User Tracking

## Testing Overview
- **Testing Start Date**: [START_DATE]
- **Testing End Date**: [END_DATE]
- **Total Invited Users**: [NUMBER]
- **Active Testers**: [NUMBER]
- **Feedback Received**: [NUMBER]

## User Categories

### Development Team
| Name | Email | Device | Status | Issues | Rating | Notes |
|------|-------|---------|--------|---------|---------|-------|
| Dev 1 | dev1@company.com | Pixel 6 | ✅ Complete | None | 5/5 | All good |
| Dev 2 | dev2@company.com | Galaxy S22 | 🔄 Testing | Minor | 4/5 | UI feedback |

### QA Team
| Name | Email | Device | Status | Issues | Rating | Notes |
|------|-------|---------|--------|---------|---------|-------|
| QA 1 | qa1@company.com | OnePlus 9 | ✅ Complete | Critical | 2/5 | Sign-in fails |
| QA 2 | qa2@company.com | Xiaomi 11 | 🔄 Testing | None | TBD | In progress |

### Beta Users
| Name | Email | Device | Status | Issues | Rating | Notes |
|------|-------|---------|--------|---------|---------|-------|
| Beta 1 | beta1@gmail.com | iPhone 13 | ❌ No response | Unknown | TBD | Need follow-up |
| Beta 2 | beta2@gmail.com | Galaxy A52 | ✅ Complete | None | 5/5 | Excellent |

## Issue Tracking

### Critical Issues
| Issue ID | Reporter | Device | Description | Status | Priority | Assigned To |
|----------|----------|---------|-------------|---------|----------|-------------|
| IT-001 | QA 1 | OnePlus 9 | Google Sign-In fails | Open | High | Dev Team |
| IT-002 | Beta 3 | Huawei P30 | App crashes on startup | Fixed | Critical | Dev Team |

### Minor Issues
| Issue ID | Reporter | Device | Description | Status | Priority | Assigned To |
|----------|----------|---------|-------------|---------|----------|-------------|
| IT-003 | Dev 2 | Galaxy S22 | UI alignment issue | Open | Low | UI Team |
| IT-004 | Beta 2 | Galaxy A52 | Slow loading | Open | Medium | Dev Team |

## Testing Progress

### Daily Progress Tracking
| Date | New Testers | Feedback Received | Issues Found | Issues Fixed |
|------|-------------|-------------------|--------------|--------------|
| 2024-01-15 | 5 | 2 | 1 | 0 |
| 2024-01-16 | 3 | 4 | 2 | 1 |
| 2024-01-17 | 2 | 3 | 1 | 2 |

### Weekly Summary
- **Week 1**: Focus on core functionality testing
- **Week 2**: Performance and edge case testing
- **Week 3**: Bug fixes and retesting

## Success Metrics

### Target Metrics
- **Participation Rate**: >80% (Target: 16/20 invited users)
- **Google Sign-In Success Rate**: >95%
- **App Crash Rate**: <0.1%
- **Average Rating**: >4.0/5.0
- **Critical Issues**: 0

### Current Metrics
- **Participation Rate**: 75% (15/20)
- **Google Sign-In Success Rate**: 87% (13/15)
- **App Crash Rate**: 0.2% (3 crashes reported)
- **Average Rating**: 3.8/5.0
- **Critical Issues**: 1

## Follow-up Actions

### High Priority
- [ ] Fix critical Google Sign-In issue (IT-001)
- [ ] Follow up with non-responsive testers
- [ ] Investigate crash reports

### Medium Priority
- [ ] Address UI alignment issues
- [ ] Optimize app loading performance
- [ ] Improve error messages

### Low Priority
- [ ] Collect more device variety feedback
- [ ] Document best practices
- [ ] Prepare for next testing phase

## Communication Log

### Sent Communications
| Date | Type | Recipients | Subject | Response Rate |
|------|------|------------|---------|---------------|
| 2024-01-15 | Email | All testers | Testing invitation | 75% |
| 2024-01-17 | Reminder | Non-responsive | Reminder to test | 40% |
| 2024-01-19 | Update | Active testers | Bug fix update | 90% |

### Received Feedback
| Date | From | Type | Priority | Status |
|------|------|------|----------|---------|
| 2024-01-16 | QA 1 | Bug report | High | In progress |
| 2024-01-17 | Beta 2 | Positive feedback | Low | Noted |
| 2024-01-18 | Dev 2 | UI suggestion | Medium | Under review |

## Next Steps

### This Week
1. Fix critical Google Sign-In issue
2. Release updated version to testers
3. Collect feedback on fixes
4. Prepare weekly summary report

### Next Week
1. Analyze all feedback
2. Decide on closed testing readiness
3. Prepare closed testing plan
4. Document lessons learned

---

**Last Updated**: [DATE]
**Updated By**: [NAME]
**Next Review**: [DATE]
EOF

    print_status "Detailed tracking template created: $DETAILED_TRACKING"
    
    echo ""
    echo "📊 Tracking Tools Created:"
    echo "1. CSV file for spreadsheet import: $TRACKING_CSV"
    echo "2. Detailed tracking template: $DETAILED_TRACKING"
    echo ""
    echo "💡 Usage Tips:"
    echo "- Import CSV into Google Sheets or Excel for easy tracking"
    echo "- Use the detailed template for comprehensive project management"
    echo "- Update tracking information daily during testing period"
    echo "- Use status indicators: ✅ Complete, 🔄 In Progress, ❌ Issue, ⏳ Waiting"
}

# Main script execution
while true; do
    show_menu
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            create_test_user_list
            ;;
        2)
            generate_invitation_emails
            ;;
        3)
            create_test_scenarios
            ;;
        4)
            generate_feedback_template
            ;;
        5)
            create_tracking_spreadsheet
            ;;
        6)
            echo ""
            print_status "Test user management completed!"
            echo ""
            echo "📁 All files created in: $TEST_USERS_DIR/"
            echo ""
            echo "🚀 Next steps:"
            echo "1. Edit test user list with real email addresses"
            echo "2. Customize invitation templates with actual information"
            echo "3. Send invitations to test users"
            echo "4. Use tracking tools to monitor progress"
            echo ""
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please select 1-6."
            ;;
    esac
done