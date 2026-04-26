# Getting Started

## Requirements

- Flutter 3.41.6
- Android Studio or VS Code with the Flutter plugin
- Android SDK or Xcode, depending on the target platform

## Setup

1. Clone this repository.

2. Install dependencies:

```bash
flutter pub get
```

3. Generate code when generated files are stale:

```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:

```bash
flutter run lib/main.dart
```

## Running The Application

### Web

```bash
flutter run -d chrome
```

### iOS

```bash
open -a Simulator
flutter run
```

### macOS

```bash
flutter run -d macos
```

### Android

```bash
flutter run -d android
```
