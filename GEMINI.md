# Project: Book Dragon

Book Dragon is a medieval-themed reading companion application built with Flutter. It aims to provide a visually rich and engaging experience for readers.

## Core Technologies
- **Framework**: Flutter (Dart)
- **Styling**: Material Design with a custom dark theme (`lib/theme/app_theme.dart`).
- **Networking**: `http` package for API interactions.
- **Storage**: `shared_preferences` for local data persistence.
- **Fonts**: `google_fonts` for medieval-inspired typography.

## General Instructions
- **Visual Excellence**: Maintain a polished, immersive medieval aesthetic. Use the established dark theme and dragon-themed assets.
- **Code Quality**: Follow standard Flutter/Dart conventions. Ensure all new widgets are modular and well-documented.
- **Validation**: Always run `flutter test` and `flutter analyze` after making changes to ensure code integrity.

## Coding Style
- **Formatting**: Use the standard Dart formatter (`dart format .`).
- **Naming**: 
  - Class names: `UpperCamelCase`
  - Variables/Functions: `lowerCamelCase`
  - Files: `snake_case`
- **Widgets**: Prefer `const` constructors where possible. Use `StatelessWidget` for UI that doesn't change and `StatefulWidget` (or a state management solution) for dynamic UI.
- **Linting**: Adhere to the rules defined in `analysis_options.yaml` (using `flutter_lints`).

## Dependencies & Constraints
- **Orientation**: The app is locked to portrait mode (`DeviceOrientation.portraitUp`, `DeviceOrientation.portraitDown`).
- **Status Bar**: Maintain a transparent status bar for an immersive experience.
- **New Dependencies**: Before adding new packages to `pubspec.yaml`, verify their necessity and compatibility with the current SDK version (^3.10.0).

## Project Structure
- `lib/config/`: Configuration files like API endpoints.
- `lib/models/`: Data models (e.g., `user.dart`).
- `lib/screens/`: Individual app screens (e.g., `login_screen.dart`, `home_screen.dart`).
- `lib/theme/`: Custom app themes and styling constants.
- `assets/images/`: Project-specific images (e.g., dragon mascots).
