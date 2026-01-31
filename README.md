<div align="center">

![App Logo](ehliyet_rehberim/assets/images/app_logo.png)

# Ehliyet Rehberim

*A comprehensive, modern mobile application for driving license exam preparation in Turkey.*

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/turkmenapps/ehliyet-rehberim)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev/)

</div>

---

## Overview

**Ehliyet Rehberim** is a feature-rich educational platform designed to modernize the driving license preparation process. Built with Flutter and adhering to clean architecture principles, it addresses common market gaps such as poor user experience and lack of detailed explanations.

The application combines rigorous academic content with gamification elements to enhance user retention and learning efficiency.

## Key Features

### Smart Quiz System
*   **Comprehensive Database**: Over 1000 official questions with detailed reasoning for every answer.
*   **Adaptive Learning**: Algorithms that identify weak areas and tailor practice sessions accordingly.
*   **Exam Simulation**: 20 full-length practice exams that mimic real testing conditions.

### Analytics & Tracking
*   **Performance Dashboard**: Visual analytics for tracking progress across different topic categories.
*   **Success Metrics**: Detailed breakdown of accuracy rates and improvement trends over time.

### Gamification
*   **Motivation Engine**: Daily goals, streak tracking, and achievement badges to foster consistent study habits.
*   **Progress Visualization**: Interactive charts and milestone tracking.

### User Experience
*   **Modern Design**: Implementation of Material Design 3 with support for dynamic light and dark themes.
*   **Offline Capability**: Full functionality available without an active internet connection.
*   **Multi-Platform**: Native performance on both iOS and Android devices.

## Technical Architecture

The project follows a **Feature-First Clean Architecture** to ensure scalability, testability, and maintainability.

### Core Technologies
*   **Framework**: Flutter & Dart
*   **State Management**: Riverpod (Reactive, compile-time safe)
*   **Authentication**: Firebase Auth (Google, Apple, Anonymous)
*   **Backend Services**: Firebase (Firestore, Cloud Functions)
*   **Monetization**: RevenueCat (In-App Purchases), AdMob

### Architecture Layers
1.  **Presentation Layer**: UI Components and Widgets (Passive views).
2.  **Application Layer**: Logic holders (Riverpod Providers) managing state and user actions.
3.  **Domain Layer**: Pure Dart classes defining business entities and abstract repositories.
4.  **Data Layer**: Implementations of repositories, data sources, and API handling.

```
lib/
├── main.dart                          # Application entry point
├── src/
│   ├── core/                          # Shared kernel (utils, services, theme)
│   └── features/                      # Modular features (auth, quiz, profile)
│       ├── application/               # State management logic
│       ├── domain/                    # Business entities & interfaces
│       ├── data/                      # Repository implementations
│       └── presentation/              # Widgets & Screens
```

## Getting Started

### Prerequisites
*   Flutter SDK: 3.29.3+
*   Dart SDK: 3.8.1+

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/turkmenapps/ehliyet-rehberim.git
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the application:
    ```bash
    flutter run
    ```

## Development Standards

*   **Linting**: Uncompromising adherence to strict Dart analysis options.
*   **Formatting**: Codebase is automatically formatted using `dart format`.
*   **Testing**: Comprehensive unit and widget tests covering core business logic.

## Contact

**Ümmügülsün Türkmen**

[LinkedIn](https://linkedin.com/in/ummugulsunturkmen) | [Portfolio](https://ummugulsun.me) | [Email](mailto:ummugulsunturkmen@gmail.com)
