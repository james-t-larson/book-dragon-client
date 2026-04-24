# **Project: Book Dragon**

Book Dragon is a medieval-themed reading companion application built with Flutter. It aims to provide a visually rich and engaging experience for readers.

## **Core Technologies**

* **Framework**: Flutter (Dart)  
* **Styling**: Material Design with a custom dark theme (lib/theme/app\_theme.dart).  
* **Networking**: http package for API interactions.  
* **Storage**: shared\_preferences for local data persistence.  
* **Fonts**: google\_fonts for medieval-inspired typography.  
* **State Management**: BLoC (Business Logic Component).  
* **Architecture**: MVVM (Model-View-ViewModel).

## **General Instructions**

* **Visual Excellence**: Maintain a polished, immersive medieval aesthetic. Use the established dark theme and dragon-themed assets.  
* **Code Quality**: Follow standard Flutter/Dart conventions. Ensure all new widgets are modular and well-documented.  
* **Validation**: While the user will handle final flutter test and flutter analyze runs, ensure logic is sound before submitting changes.

## **Coding Style**

* **Formatting**: Use the standard Dart formatter (dart format .).  
* **Naming**:  
  * Class names: UpperCamelCase  
  * Variables/Functions: lowerCamelCase  
  * Files: snake\_case  
* **Widgets**: Prefer const constructors where possible. Use StatelessWidget for UI that doesn't change and StatefulWidget (or BLoC/Providers) for dynamic UI.  
* **Linting**: Adhere to the rules defined in analysis\_options.yaml (using flutter\_lints).

## **Dependencies & Constraints**

* **Orientation**: The app is locked to portrait mode (DeviceOrientation.portraitUp, DeviceOrientation.portraitDown).  
* **Status Bar**: Maintain a transparent status bar for an immersive experience.  
* **New Dependencies**: Before adding new packages to pubspec.yaml, verify their necessity and compatibility with the current SDK version (^3.10.0).

## **Project Structure**

* lib/config/: Configuration files like API endpoints.  
* lib/models/: Data models (e.g., user.dart).  
* lib/screens/: Individual app screens (e.g., login\_screen.dart, home\_screen.dart).  
* lib/theme/: Custom app themes and styling constants.  
* assets/images/: Project-specific images (e.g., dragon mascots).

## **Developer Workflow & Environment**

* **Documentation**: All detailed project info is located in /docs.  
* **File Structure**: Run cat ./docs/file-structure.txt if you need to understand the comprehensive directory layout.  
* **Flutter CLI**: If you need to run any flutter command, use the absolute path: /Users/jameslarson/Projects/flutter/bin/flutter \<command\>.  
* **Verification**: Avoid running tests and analysis commands (e.g., flutter test, flutter analyze) if possible; the user will handle this verification.  
* **Backend Testing**: To test the backend, use localhost:8080. Authenticate first via curl and store the token in a temporary file for subsequent requests.  
* **Architecture Enforcement**: Strictly follow the **MVVM** pattern and utilize **BLoC** for all state management logic.
