<div align="center">

![App Logo](assets/images/app_logo.png)

# Ehliyet Rehberim

*A comprehensive, modern mobile application for driving license exam preparation in Turkey.*

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/turkmenapps/ehliyet-rehberim)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)

</div>

---

## 📖 Overview

**Ehliyet Rehberim** is a high-performance educational platform designed to modernize the driving license preparation process in Turkey. By leveraging **Flutter**'s cross-platform capabilities and **Clean Architecture** principles, it delivers a superior user experience compared to traditional alternatives.

The application combines rigorous academic content (1000+ official questions) with advanced gamification elements (streaks, badges, leaderboards) to maximize user retention and learning efficiency.

---

## ✨ Key Features

### 🧠 **Smart Quiz System**
*   **Deep Learning Database**: Over 1000 official questions, each with detailed reasoning and explanations.
*   **Adaptive Algorithms**: The system identifies weak topic areas and automatically tailors practice sessions to close knowledge gaps.
*   **Realistic Simulation**: 20 full-length practice exams that mimic the real exam conditions (50 questions, 45 minutes).

### 📊 **Advanced Analytics Dashboard**
*   **Visual Tracking**: Interactive charts showing progress across 5 major categories (First Aid, Traffic, Engine, etc.).
*   **Success Metrics**: Detailed breakdown of accuracy rates, daily activity, and improvement trends.
*   **Readiness Score**: A calculated score predicting the user's likelihood of passing the real exam.

### 🔥 **Gamification & Engagement**
*   **Motivation Engine**: Daily goals, streak tracking, and "Combo" mechanics to foster consistent study habits.
*   **Achievement System**: Unlockable badges and milestones for completing specific challenges.
*   **Interactive Onboarding**: A persuasive, 2-phase onboarding flow that personalizes the user's study plan immediately.

### 💎 **Premium Experience**
*   **Ad-Free Learning**: Optional subscription model via RevenueCat.
*   **Cloud Sync**: Secure progress backup using Firebase Auth (Google, Apple, Anonymous).
*   **Modern UI/UX**: Material Design 3 implementation with support for dynamic light/dark themes.

---

## 📸 Screenshots

<div align="center">
  <img src="screenshots/home.png" width="250" alt="Home Screen" />
  <img src="screenshots/quiz.png" width="250" alt="Quiz Interface" />
  <img src="screenshots/stats.png" width="250" alt="Analytics" />
</div>

> *Note: Screenshots demonstrate the Home Dashboard, Quiz Interface, and Statistics screens.*

---

## 🛠 Technical Architecture

The project is built on a **Feature-First Clean Architecture** foundation, ensuring scalability, testability, and separation of concerns.

### Core Stack
*   **Framework**: Flutter & Dart (Latest stable versions)
*   **State Management**: `flutter_riverpod` (Reactive, compile-time safe dependency injection)
*   **Backend**: Firebase (Auth, Firestore, Remote Config)
*   **Monetization**: RevenueCat (IAP), Google Mobile Ads

### Architecture Layers
1.  **Presentation Layer**: 
    *   Passive Views (Widgets)
    *   Controllers/Notifiers (Riverpod providers)
2.  **Domain Layer**: 
    *   Pure Dart Entities (Business logic)
    *   Abstract Repository Interfaces
3.  **Data Layer**: 
    *   Repository Implementations
    *   Data Sources (API, Local Storage)
    *   DTOs (Data Transfer Objects)

### Project Structure
```
lib/
├── src/
│   ├── core/                  # Shared kernel (Services, Utils, Theme)
│   └── features/              # Modular feature slices
│       ├── auth/              # Authentication & Onboarding
│       ├── quiz/              # Exam & Question Logic
│       ├── home/              # Dashboard
│       └── stats/             # Analytics
```

---

## 🚀 Getting Started

### Prerequisites
*   **Flutter SDK**: 3.29.3 or higher
*   **Dart SDK**: 3.8.1 or higher
*   **IDE**: VS Code (Recommended) or Android Studio

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/turkmenapps/ehliyet-rehberim.git
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the application**
    ```bash
    flutter run
    ```

---

## 🧪 Quality Assurance

We maintain high code quality standards through:
*   **Linting**: Strict Dart analysis rules enabled.
*   **Formatting**: Automated `dart format` on pre-commit.
*   **Testing**: Unit tests for core business logic (Allocated in `test/`).

---

## 📞 Contact

**Ümmügülsün Türkmen**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/ummugulsunturkmen)
[![Portfolio](https://img.shields.io/badge/Portfolio-FF5722?style=for-the-badge&logo=google-chrome&logoColor=white)](https://ummugulsun.me)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:ummugulsunturkmen@gmail.com)

---

<div align="center">
  <i>Built with ❤️ using Flutter</i>
</div>
