# Number Master 🎯

A challenging number matching puzzle game built with Flutter, where players match numbers that are identical or sum to 10 by connecting them through clear paths.

## 🎮 Game Overview

Number Master is an engaging puzzle game that challenges your logical thinking and pattern recognition skills. The game features a dynamic grid system that expands as you progress, offering increasingly complex challenges across multiple levels.

### 🎯 Game Rules
- **Match Numbers**: Connect numbers that are either identical or sum to 10
- **Path Requirements**: Numbers must be connected through adjacent cells or clear lines of sight
- **Grid Expansion**: Start with 3 rows and unlock up to 7 rows as you progress
- **Time Challenge**: Complete levels within the time limit
- **Score System**: Earn points based on matches and level multipliers

### 🚀 Features
- **7-Level Grid System**: Dynamic grid that expands from 3 to 7 rows
- **Smart Matching**: Identical numbers or pairs that sum to 10
- **Path Validation**: Advanced algorithm for checking valid connections
- **Visual Feedback**: Smooth animations and haptic feedback
- **Progress Tracking**: Save game state and progress
- **Hint System**: Get help when stuck
- **Row Addition**: Strategically add new rows to the grid
- **Cross-Platform**: Available on Android, iOS, Windows, and Web

## 🛠️ Technical Details

### Built With
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **SharedPreferences**: Local data persistence
- **Sizer**: Responsive design utilities
- **Material Design**: Modern UI components

### Architecture
- **Clean Architecture**: Organized presentation, domain, and data layers
- **State Management**: Flutter's built-in StatefulWidget system
- **Widget Composition**: Modular, reusable UI components
- **Responsive Design**: Adapts to different screen sizes

## 📱 Platforms Supported

- ✅ **Android** (APK available)
- ✅ **iOS** 
- ✅ **Windows Desktop**
- ✅ **Web Browser**

## 📥 Download & Installation

### Android APK
The latest release APK is available at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### From Source
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd number_master
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For Windows
   flutter run -d windows
   
   # For Web
   flutter run -d chrome
   ```

## 🏗️ Building the App

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### Windows Executable
```bash
flutter build windows --release
```

### Web Build
```bash
flutter build web --release
```

## 🎨 Project Structure

```
lib/
├── core/
│   └── app_export.dart
├── main.dart
├── presentation/
│   ├── game_completion_screen/
│   ├── game_screen/
│   ├── home_screen/
│   ├── level_completion_screen/
│   ├── settings_screen/
│   └── splash_screen/
├── routes/
│   └── app_routes.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── custom_error_widget.dart
    ├── custom_icon_widget.dart
    └── custom_image_widget.dart
```

## 🎯 Game Mechanics

### Grid System
- **Initial State**: 3 active rows with random numbers 1-9
- **Expansion**: Add rows up to maximum of 7
- **Inactive Rows**: Display as empty (grayed out)

### Matching Logic
- **Direct Match**: Same number (e.g., 5 + 5)
- **Sum Match**: Numbers that add to 10 (e.g., 3 + 7, 4 + 6)
- **Path Validation**: Checks for clear lines between cells

### Scoring System
- **Base Score**: 10 points per match
- **Level Multiplier**: Increases with each level
- **Bonus Points**: Time bonuses and efficiency rewards

## 🔧 Development Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### Environment Setup
1. Install Flutter SDK
2. Configure Android/iOS development environment
3. Install required dependencies
4. Set up code signing for releases

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

## 📊 Performance Features

- **Optimized Rendering**: Efficient grid rendering with custom painters
- **Memory Management**: Proper disposal of controllers and timers
- **Smooth Animations**: 60fps animations with proper vsync
- **Responsive UI**: Adapts to different screen sizes and orientations

## 🎨 UI/UX Features

- **Material Design**: Modern, intuitive interface
- **Dark/Light Themes**: Adaptive theming system
- **Haptic Feedback**: Tactile response for interactions
- **Smooth Transitions**: Animated screen transitions
- **Accessibility**: Support for screen readers and accessibility tools

## 🚀 Future Enhancements

- [ ] **Multiplayer Mode**: Online competitive play
- [ ] **Custom Themes**: User-selectable color schemes
- [ ] **Achievement System**: Unlockable badges and rewards
- [ ] **Statistics Tracking**: Detailed game analytics
- [ ] **Sound Effects**: Audio feedback and background music
- [ ] **Cloud Save**: Cross-device progress synchronization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**🎮 Ready to master numbers? Download the APK and start playing!**

*APK Location: `build/app/outputs/flutter-apk/app-release.apk`*
