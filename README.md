# MultiCult

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)


Application for Jeju Multicultural Population's Better Medical Access


## Technical Stack

- **Framework**: Flutter 3.8.0+
- **Language**: Dart
- **UI Components**: Material Design
- **State Management**: StatefulWidget with setState
- **Platform Support**: iOS, Android, Web, macOS, Linux, Windows


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

3. Set up OpenAI API integration:
```bash
# Copy the environment template
cp .env.example .env

# Edit .env and add your OpenAI API key
# OPENAI_API_KEY=your_actual_api_key_here
```

4. Run the app:
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
├── quiz.dart          # Quiz functionality with typing and MCQ
├── chat.dart          # AI-powered chat with OpenAI integration
├── settings.dart      # Settings page with editable fields
├── globals.dart       # Global variables and data
└── openai_service.dart # OpenAI API integration service
```

## Key Features Implementation

### AI-Powered Chat
- **OpenAI Integration**: Real-time conversations with GPT-3.5-turbo
- **Language Learning Focus**: Specialized prompts for multicultural language learning
- **Loading States**: Visual feedback during API calls
- **Error Handling**: Graceful fallbacks for network issues

### Interactive Quiz System
- **Multiple Question Types**: MCQ, typing, and matching questions
- **Answer Validation**: Smart checking with override options
- **Responsive UI**: Fixed text input and overflow issues
- **Progress Tracking**: Visual feedback and scoring

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
