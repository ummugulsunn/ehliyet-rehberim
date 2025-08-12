# 🚗 Ehliyet Rehberim (Turkish Driving License Prep)

A modern, user-friendly Flutter application designed for Turkish driving license exam preparation. Built with Material Design 3 and supporting both light and dark themes.

## ✨ Features

### 📚 Comprehensive Question Bank
- **20 practice exams** with complete coverage
- **1000+ questions** organized across categories:
  - 🚑 First Aid
  - 🔧 Vehicle Mechanics & Technology
  - 🤝 Traffic Ethics
  - 🛑 Traffic Signs
  - 🌍 Traffic & Environmental Knowledge

### 🎯 Smart Learning System
- **Topic-based study** - Choose and focus on specific subjects
- **Exam mode** - Authentic exam experience with timer
- **Detailed explanations** - Comprehensive answers for every question
- **Progress tracking** - Monitor your improvement over time
- **Adaptive learning** - Focus on weak areas automatically

### 💎 Premium Features
- **Pro subscription** - Access to all features
- **20 practice exams** - Complete exam simulation
- **1000+ questions** - Full question database
- **Ad-free experience** - Uninterrupted studying
- **Advanced analytics** - Detailed performance insights

## 🚀 Installation

### Requirements
- Flutter 3.29.3 or higher
- Dart 3.7.0 or higher
- Android Studio / VS Code
- Android SDK (API 21+)
- iOS 12.0+ (for iOS build)

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/ehliyet-rehberim.git
cd ehliyet-rehberim
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
flutter run
```

## 📱 Screenshots

### Home Screen
- Modern Material Design 3 interface
- Intuitive navigation
- Dark/Light theme support
- Progress tracking dashboard

### Topic Selection
- Categorized question organization
- Visual icons for easy identification
- Progress indicators per category
- Smart recommendations

### Exam Interface
- Clean, readable interface
- Progress indicators
- Real-time feedback
- Timer and scoring system

## 🏗️ Project Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── models/
│   │   │   ├── exam_model.dart
│   │   │   ├── question_model.dart
│   │   │   └── study_guide_model.dart
│   │   ├── services/
│   │   │   ├── quiz_service.dart
│   │   │   ├── purchase_service.dart
│   │   │   └── user_progress_service.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       └── enhanced_pro_banner.dart
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── quiz/
│   │   ├── exams/
│   │   ├── topics/
│   │   ├── stats/
│   │   ├── paywall/
│   │   └── profile/
│   └── main.dart
├── assets/
│   ├── data/
│   │   ├── exams.json
│   │   ├── traffic_signs.json
│   │   └── study_guides.json
│   └── images/
└── test/
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/quiz/application/quiz_providers_test.dart

# Run with coverage
flutter test --coverage
```

## 📦 Build

### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Split APK for different architectures
flutter build apk --release --split-per-abi
```

### iOS
```bash
# iOS build
flutter build ios --release
```

### Web
```bash
# Web build
flutter build web --release
```

## 🔧 Configuration

### Dependencies
Key dependencies used in this project:
- `flutter_riverpod` - State management
- `google_fonts` - Typography
- `firebase_auth` - Authentication
- `purchases_flutter` - In-app purchases
- `shared_preferences` - Local storage

### Development Setup
1. Ensure Flutter SDK is properly installed
2. Configure Firebase project (optional)
3. Set up RevenueCat for subscription management (optional)

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## 🛠️ Technical Stack

- **Framework**: Flutter 3.29.3+
- **Language**: Dart 3.7.0+
- **State Management**: Riverpod
- **Architecture**: Clean Architecture with Feature-first approach
- **Design System**: Material Design 3
- **Platforms**: Android, iOS, Web

## 📈 Performance

- Optimized for 60fps performance
- Lazy loading for large datasets
- Efficient memory management
- Dark/Light theme switching
- Responsive design for all screen sizes

---

⭐ If you found this project helpful, please consider giving it a star!
