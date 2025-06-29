# MultiCult

A Flutter application designed to explore and celebrate multiculturalism through interactive quizzes and personalized settings.

## About

MultiCult is a cross-platform mobile application built with Flutter that aims to promote cultural awareness and understanding. The app features interactive quizzes about different cultures and allows users to customize their experience through comprehensive settings.

## Features

- **Interactive Quiz System**: Engage with questions about various cultures and traditions
- **Personalized Settings**: Customize your profile with editable information
  - Editable email and name fields
  - Scrollable birth year picker for clean user experience
  - Multi-language support with expandable language selection
- **Modern UI Design**: Dark theme with elegant card-based layout
- **Cross-Platform**: Works on iOS, Android, Web, macOS, Linux, and Windows

## Technical Stack

- **Framework**: Flutter 3.8.0+
- **Language**: Dart
- **UI Components**: Material Design
- **State Management**: StatefulWidget with setState
- **Platform Support**: iOS, Android, Web, macOS, Linux, Windows

## Screenshots

The app features a clean, modern interface with:
- Home screen with navigation
- Interactive quiz interface
- Comprehensive settings page with editable fields
- Multi-language support

## Getting Started

### Prerequisites

- Flutter SDK (3.8.0 or higher)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)
- For mobile development: Android Studio/Xcode

### Installation

1. Clone the repository:
```bash
git clone https://github.com/[your-username]/MultiCult.git
cd MultiCult
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Different Platforms

- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`
- **macOS**: `flutter build macos`
- **Linux**: `flutter build linux`
- **Windows**: `flutter build windows`

## Project Structure

```
lib/
├── main.dart          # Entry point and navigation
├── home.dart          # Home screen implementation
├── quiz.dart          # Quiz functionality
├── settings.dart      # Settings page with editable fields
└── globals.dart       # Global variables and data
```

## Key Features Implementation

### Editable Settings
- **Text Fields**: Email and name editing through dialog boxes
- **Birth Year Picker**: Smooth scrollable wheel picker for year selection
- **Language Selection**: Expandable dropdown with flag and name display

### Quiz System
- Interactive quiz interface
- Cultural awareness questions
- Engaging user experience

### Multi-Platform Support
- Responsive design for different screen sizes
- Platform-specific adaptations
- Consistent user experience across devices


## Authors

- **Joy Kim, Sang Ahn, Ethan Cho, Soomin Kim, Alisa Kim, Zijun Huang**


If you have any questions or need support, please open an issue on GitHub.

---

Made with ❤️ using Flutter
