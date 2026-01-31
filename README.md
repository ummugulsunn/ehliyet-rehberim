# Ehliyet Rehberim

![Flutter Version](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Dart Version](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg?style=flat)

## About the Project

Ehliyet Rehberim is a comprehensive mobile application designed to assist users in preparing for the Turkish Driver's License Exam. It offers a robust platform featuring over 20 practice exams, detailed topic explanations, and visual study aids for traffic signs. The application is built with a focus on user experience, performance, and educational efficacy, utilizing data-driven insights to track user progress and highlight areas for improvement.

## Key Features

- **Extensive Exam Repository:** Access to 20+ full-length practice exams simulating real testing conditions.
- **Advanced Analytics:** Detailed statistical analysis of user performance using interactive charts, allowing for targeted study sessions.
- **Visual Learning Tools:** sophisticated modules for learning traffic signs and vehicular information.
- **Dynamic Quiz Engine:** Interactive quiz interface with real-time feedback, confetti celebrations for achievements, and state preservation.
- **Personalized Experience:** specific study guides, favorites system for difficult questions, and personal note-taking capabilities.
- **Secure Authentication:** Robust user authentication system supporting Email, Google, and Apple Sign-In via Firebase.
- **Offline Persistence:** Local data caching ensures continuous learning progress is saved even without an active internet connection.

## Technology Stack

This project leverages a modern and scalable technology stack:

- **Framework:** Flutter (3.8.1+)
- **Language:** Dart
- **State Management:** Riverpod (2.6.1) for reactive and testable state management.
- **Backend & Auth:** Firebase (Auth, Firestore, Core) for secure backend services.
- **Visualization:** FL Chart for rendering complex statistical data.
- **UI Components:** Google Fonts (Inter), Confetti, Smooth Page Indicator.
- **Local Storage:** SharedPreferences for efficient local data persistence.
- **Architecture:** Feature-first, clean architecture emphasizing separation of concerns and maintainability.

## Prerequisites

Before running this project, ensure you have the following installed:

- **Flutter SDK:** Version 3.8.1 or later.
- **Dart SDK:** Compatible version included with Flutter.
- **IDE:** VS Code or Android Studio with Flutter/Dart plugins.
- **Git:** For version control.
- **CocoaPods:** (MacOS only) For managing iOS dependencies.

## Installation & Usage

Follow these steps to set up the project locally:

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/Start-Up-Academy-Mobile-App/ehliyet-rehberim.git
    cd ehliyet-rehberim
    ```

2.  **Install Dependencies**

    ```bash
    flutter pub get
    ```

3.  **Setup Firebase**
    
    Ensure you have the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files placed in their respective directories (`android/app` and `ios/Runner`).

4.  **Run the Application**

    ```bash
    flutter run
    ```

## Project Architecture

The project follows a **Feature-First** architecture, ensuring high modularity and scalability. Each feature is encapsulated with its own Domain, Data, and Presentation layers.

```text
lib/
├── src/
│   ├── features/
│   │   ├── auth/           # Authentication logic and UI
│   │   ├── home/           # Main dashboard and navigation
│   │   ├── quiz/           # Quiz engine and state management
│   │   ├── stats/          # User progress analytics
│   │   ├── profile/        # User profile management
│   │   ├── favorites/      # Bookmarking functionality
│   │   └── ...
│   ├── common_widgets/     # Reusable UI components
│   ├── constants/          # App-wide constants and theme
│   ├── utils/              # Helper functions and extensions
│   ├── routing/            # Navigation configuration
│   └── localization/       # Internationalization support
└── main.dart               # Application entry point
```

## Contributing

Contributions are welcome. Please adhere to the following guidelines:

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

Please ensure your code follows the project's linting rules and "Clean Code" principles.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
