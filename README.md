# 🐉 Book Dragon

**Book Dragon** is your medieval-themed reading companion, designed to help you track your reading progress, set focus timers, and collect magical dragons as you achieve your reading goals.

Built with **Flutter**, this cross-platform application features a premium, parchment-inspired design and a medieval aesthetic.

---

## ✨ Features

- **📖 Reading Tracker**: Log your books, track current pages, and see your reading history.
- **⏱️ Focus Timer**: A dedicated timer to help you stay focused on your reading sessions and earn rewards.
- **🐲 Dragon Collection**: Choose your companion dragon and watch it grow as you read more.
- **🏰 Medieval Aesthetic**: Premium UI experience using curated Google Fonts (`MedievalSharp`, `Rosarivo`) and a harmonious historical color palette.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed on your machine:

1. **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (version 3.10.0 or higher recommended).
2. **Dart SDK**: Included with Flutter.
3. **Development Tools**:
   - **Android**: Android Studio with the Flutter plugin installed.
   - **iOS/macOS**: Xcode (latest version) and [CocoaPods](https://cocoapods.org/) installed (`brew install cocoapods`).
   - **Web**: Chrome or any modern web browser.

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/james-t-larson/book-dragon-client.git
cd book-dragon-client
```

### 2. Install Dependencies

Fetch all the necessary Flutter packages:

```bash
flutter pub get
```

### 3. iOS Setup (macOS only)

If you are planning to run on an iOS device or simulator, navigate to the `ios` directory and install the pods:

```bash
cd ios
pod install
cd ..
```

---

## ⚙️ Configuration

The application communicates with a backend API. By default, it points to `http://localhost:8080`. You can override this during development or for production using `--dart-define`.

To run with a custom API base URL:

```bash
--dart-define=API_BASE_URL=https://your-api-domain.com
```

---

## 🖥️ Running the Application

### Debug Mode

Run the app on your connected device or simulator:

```bash
# Standard run
flutter run

# Run with custom API URL
flutter run --dart-define=API_BASE_URL=http://<YOUR_IP>:8080
```

### Running on Specific Platforms

- **Android**: `flutter run -d android`
- **iOS**: `flutter run -d ios`
- **Web**: `flutter run -d chrome`

---

## 📦 Building for Production

### Android

Generate a release APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.bookdragon.com
```

### iOS

Generate an iOS build (Archive):

```bash
flutter build ios --release --no-codesign --dart-define=API_BASE_URL=https://api.bookdragon.com
```

### Web

Generate a production-ready web build:

```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.bookdragon.com
```

---

## 🧪 Testing

Run the widget and unit tests to ensure everything is working correctly:

```bash
flutter test
```

---

## 🎨 Design System

The app utilizes a custom styling system based on medieval themes:
- **Fonts**: `MedievalSharp` (Titles), `Rosarivo` (Body Content).
- **Colors**: Maroon, London Blue, Green, and Slate Grey.
- **Assets**: Hand-crafted dragon illustrations located in `assets/images/`.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an issue for any bugs or feature requests.

---

*Happy Reading, Dragon Master!* 📚🔥
