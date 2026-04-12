class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String appStoreLinkApple = String.fromEnvironment(
    'APP_STORE_LINK_APPLE',
    defaultValue: 'https://apps.apple.com/app/id123456789',
  );

  static const String appStoreLinkAndroid = String.fromEnvironment(
    'APP_STORE_LINK_ANDROID',
    defaultValue: 'https://play.google.com/store/apps/details?id=com.example.app',
  );
}
