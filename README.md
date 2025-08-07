# ZenTick - macOS Desktop Timer App

A beautiful and minimal macOS desktop timer application built with Flutter, designed to help you focus and manage your time effectively.

## Features

- **Simple Countdown Timer**: Set custom durations (15, 25, 30, 45, or 60 minutes)
- **Intuitive Controls**: Start, pause, and reset functionality
- **Focus Mode**: Minimalist always-on-top sticky window that stays visible while you work
- **macOS Native Integration**: Proper window management and system sounds
- **Clean Design**: Beautiful, distraction-free interface following macOS design principles

## Focus Mode

The unique "Focus Mode" feature allows you to:
- Minimize the main window to reduce distractions
- Display a small, always-on-top timer window
- Keep track of remaining time across all applications
- Exit focus mode with a single click

## Installation

### Prerequisites
- Flutter SDK installed
- macOS development environment
- Xcode for macOS app development

### Building from Source

1. Clone this repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run -d macos
   ```

### Building for Release

```bash
flutter build macos --release
```

The built app will be available in `build/macos/Build/Products/Release/zentick.app`

## Dependencies

- **flutter**: The Flutter SDK
- **window_manager**: For native macOS window management
- **provider**: State management
- **audioplayers**: Sound notifications
- **cupertino_icons**: iOS-style icons

## Development

This app uses Flutter's Provider pattern for state management and native macOS window controls for the focus mode functionality.

### Project Structure

```
lib/
├── main.dart                 # App entry point and main widget
├── models/
│   └── timer_state.dart     # Timer state management
├── services/
│   ├── window_service.dart  # Window management
│   └── sound_service.dart   # Audio notifications
└── widgets/
    ├── main_timer_view.dart # Main timer interface
    └── focus_timer_view.dart # Focus mode interface
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
