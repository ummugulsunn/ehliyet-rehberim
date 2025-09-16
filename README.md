<div align="center">
  
![App Logo](ehliyet_rehberim/assets/images/app_logo.png)

# Ehliyet Rehberim: A Modern Driving License Exam Prep App

*A feature-rich, gamified, and user-friendly mobile application built with Flutter to help users in Turkey pass their driving license exam.*

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/turkmenapps/ehliyet-rehberim)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.1-orange.svg)](https://github.com/turkmenapps/ehliyet-rehberim/releases)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue.svg?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg?logo=dart)](https://dart.dev/)

</div>

---

## 📋 Table of Contents

- [About The Project](#-about-the-project)
- [Key Features](#-key-features)
- [Tech Stack](#-tech-stack)
- [Screenshots](#-screenshots)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Architecture](#-architecture)
- [Testing](#-testing)
- [Contact](#-contact)

---

## 🎯 About The Project

The Turkish driving license exam preparation market is dominated by outdated applications with poor user experience, intrusive advertisements, and lack of comprehensive explanations. **Ehliyet Rehberim** addresses these pain points by delivering a modern, clean, and educationally-focused solution.

Our app stands out through:
- **🎨 Superior User Experience**: Built with Flutter and Material Design 3, featuring intuitive navigation and beautiful animations
- **📖 Deeper Learning**: Every question includes detailed explanations to ensure true understanding, not just memorization  
- **🎮 Gamification**: Daily goals, streak counters, and achievement systems keep users motivated throughout their learning journey
- **⚡ Performance**: Optimized for speed with local data storage and efficient state management

*Transforming exam preparation from a tedious task into an engaging learning experience.*

---

## ✨ Key Features

### 🧠 **Smart Quiz System**
- **1000+ Official Questions** with detailed explanations for every answer
- **20 Complete Practice Exams** mimicking the real exam format
- **Topic-Based Learning** across 5 major categories (First Aid, Vehicle Mechanics, Traffic Ethics, Traffic Signs, Environmental Knowledge)
- **Adaptive Learning Algorithm** that focuses on weak areas

### 📊 **Advanced Analytics Dashboard** 
- **Personal Progress Tracking** with visual charts and trends
- **Category Performance Analysis** to identify strengths and weaknesses  
- **Success Rate Monitoring** with detailed breakdowns
- **Recent Activity Timeline** showing learning patterns

### 🔥 **Gamification & Motivation**
- **Daily Goals & Streaks** to maintain consistent study habits
- **Achievement System** with unlockable badges and milestones
- **Combo Scoring** for consecutive correct answers
- **Progress Celebrations** with confetti animations

### 🚀 **Modern & Fast Performance**
- **Material Design 3** with dynamic theming (light/dark mode)
- **Offline-First Architecture** for uninterrupted studying
- **Smooth Animations** and micro-interactions for enhanced UX
- **Cross-Platform** support for iOS and Android

### 💎 **Premium Experience**
- **Ad-Free Learning** for Pro subscribers
- **Advanced Statistics** with detailed analytics
- **Cloud Sync** via Firebase for progress backup
- **Multiple Authentication** options (Google, Apple, Guest)

---

## 🛠 Tech Stack

<div align="center">

### **Frontend & Framework**
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

### **State Management & Architecture**
![Riverpod](https://img.shields.io/badge/Riverpod-00D4AA?style=for-the-badge&logo=flutter&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-4285F4?style=for-the-badge)

### **Backend & Services**
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![RevenueCat](https://img.shields.io/badge/RevenueCat-FF6B35?style=for-the-badge)
![Google Mobile Ads](https://img.shields.io/badge/AdMob-EA4335?style=for-the-badge&logo=google&logoColor=white)

### **Authentication**
![Google Sign-In](https://img.shields.io/badge/Google%20Sign--In-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Sign in with Apple](https://img.shields.io/badge/Sign%20in%20with%20Apple-000000?style=for-the-badge&logo=apple&logoColor=white)

### **Development & Testing**
![Integration Tests](https://img.shields.io/badge/Integration%20Tests-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Unit Tests](https://img.shields.io/badge/Unit%20Tests-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Mockito](https://img.shields.io/badge/Mockito-25A162?style=for-the-badge)

</div>

### **Core Dependencies**
- **`flutter_riverpod`** - Reactive state management with compile-time safety
- **`firebase_auth`** - Secure user authentication and account management
- **`purchases_flutter`** - Cross-platform in-app purchase handling via RevenueCat
- **`google_mobile_ads`** - Non-intrusive advertisement integration
- **`shared_preferences`** - Local data persistence for user progress
- **`google_fonts`** - Beautiful typography with Inter font family
- **`confetti`** - Celebration animations for achievements
- **`connectivity_plus`** - Network status monitoring
- **`flutter_local_notifications`** - Study reminder system

---

## 📱 Screenshots

<div align="center">

| Home Dashboard | Quiz Interface | Statistics |
|:-:|:-:|:-:|
| ![Home](screenshots/home.png) | ![Quiz](screenshots/quiz.png) | ![Stats](screenshots/stats.png) |
| *Modern Material Design 3 with intuitive navigation* | *Clean quiz interface with progress tracking* | *Detailed analytics and performance insights* |

| Authentication | Topic Selection | Results |
|:-:|:-:|:-:|
| ![Auth](screenshots/auth.png) | ![Topics](screenshots/topics.png) | ![Results](screenshots/results.png) |
| *Multiple sign-in options with smooth UX* | *Categorized learning with visual indicators* | *Comprehensive result analysis* |

</div>

---

## 🚀 Getting Started

### **Prerequisites**
- **Flutter SDK**: 3.29.3 or higher
- **Dart SDK**: 3.8.1 or higher  
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+ (Xcode 12+)

### **Installation Steps**

1. **Clone the repository**
   ```bash
   git clone https://github.com/turkmenapps/ehliyet-rehberim.git
   cd ehliyet-rehberim/ehliyet_rehberim
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional for basic functionality)
   ```bash
   # Add your google-services.json (Android) and GoogleService-Info.plist (iOS)
   # Or use the app in offline mode with guest authentication
   ```

4. **Run the application**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode  
   flutter run --release
   
   # Specific platform
   flutter run -d ios
   flutter run -d android
   ```

5. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release --split-per-abi
   
   # iOS
   flutter build ios --release
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point
├── src/
│   ├── core/                          # Shared utilities and services
│   │   ├── models/                    # Data models
│   │   │   ├── exam_model.dart        # Exam structure definition
│   │   │   ├── question_model.dart    # Question entity model
│   │   │   └── test_result_model.dart # Test result tracking
│   │   ├── services/                  # Business logic services
│   │   │   ├── auth_service.dart      # Firebase authentication
│   │   │   ├── purchase_service.dart  # RevenueCat integration
│   │   │   ├── quiz_service.dart      # Quiz logic and scoring
│   │   │   └── user_progress_service.dart # Progress tracking
│   │   ├── theme/                     # Design system
│   │   │   ├── app_colors.dart        # Color palette
│   │   │   └── app_theme.dart         # Material Design 3 theme
│   │   ├── utils/                     # Helper utilities
│   │   │   ├── logger.dart            # Centralized logging
│   │   │   └── constants.dart         # App-wide constants
│   │   └── widgets/                   # Reusable UI components
│   │       └── enhanced_pro_banner.dart # Premium upsell widget
│   └── features/                      # Feature-based modules
│       ├── auth/                      # Authentication flow
│       │   ├── application/           # Riverpod providers
│       │   ├── domain/                # Business logic
│       │   └── presentation/          # UI screens
│       ├── home/                      # Dashboard and navigation
│       ├── quiz/                      # Quiz taking experience  
│       ├── exams/                     # Practice exam mode
│       ├── topics/                    # Topic-based learning
│       ├── stats/                     # Analytics dashboard
│       ├── paywall/                   # Premium subscription
│       └── profile/                   # User account management
├── assets/
│   ├── data/                          # Static data files
│   │   ├── exams.json                 # 20 complete practice exams
│   │   ├── traffic_signs.json         # Traffic signs database
│   │   └── study_guides.json          # Educational content
│   └── images/                        # Visual assets
└── test/                              # Unit and integration tests
```

---

## 🏗 Architecture

**Ehliyet Rehberim** follows **Clean Architecture** principles with **Feature-First** organization:

### **Design Patterns**
- **🔄 Riverpod**: Compile-time safe state management with dependency injection
- **🎯 Repository Pattern**: Abstract data layer for testability
- **📦 Service Layer**: Business logic separation from UI
- **🧩 Provider Pattern**: Reactive state management across the widget tree

### **Data Flow**
```
UI Layer (Presentation) 
    ↕️ 
Application Layer (Riverpod Providers)
    ↕️
Domain Layer (Business Logic)
    ↕️
Data Layer (Services & Models)
    ↕️
External APIs (Firebase, RevenueCat)
```

### **Key Architectural Decisions**
- **Offline-First**: Core functionality works without internet connection
- **Reactive UI**: Automatic UI updates through Riverpod streams
- **Modular Features**: Each feature is self-contained and testable
- **Clean Separation**: UI, business logic, and data layers are clearly separated

---

## 🧪 Testing

### **Test Coverage**
- **Unit Tests**: Core business logic and services
- **Widget Tests**: UI component behavior
- **Integration Tests**: End-to-end user flows
- **Golden Tests**: Visual regression testing

### **Running Tests**
```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run integration tests
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

# Run specific test file
flutter test test/features/quiz/application/quiz_providers_test.dart
```

### **Test Structure**
```
test/
├── core/                              # Core services testing
│   ├── services/                      # Service layer tests
│   └── models/                        # Data model tests
├── features/                          # Feature-specific tests
│   ├── auth/                          # Authentication tests
│   ├── quiz/                          # Quiz logic tests
│   └── stats/                         # Statistics tests
├── integration_test/                  # E2E tests
│   ├── auth_flow_integration_test.dart
│   └── quiz_flow_integration_test.dart
└── widget_test.dart                   # Widget testing utilities
```

---

## 👨‍💻 Contact

**Ümmügülsün Türkmen**  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/ummugulsunturkmen)
[![Portfolio](https://img.shields.io/badge/Portfolio-FF5722?style=for-the-badge&logo=google-chrome&logoColor=white)](https://ummugulsun.me)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:ummugulsunturkmen@gmail.com)

---

<div align="center">

### 🌟 Star this repository if you found it helpful!

**Built with ❤️ using Flutter**

*Empowering learners to succeed in their driving license journey through technology*

</div>
