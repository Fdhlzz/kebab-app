class AppConstants {
  // ---------------------------------------------------------------------------
  // 1. Remove 'const'. Change to 'static String'.
  // This allows us to overwrite it at runtime!
  // ---------------------------------------------------------------------------
  static String baseUrl = 'http://172.16.121.93:8000'; // Default fallback

  // ---------------------------------------------------------------------------
  // 2. Use 'get' (Getters).
  // This ensures that if baseUrl changes, these update automatically.
  // ---------------------------------------------------------------------------
  static String get apiUrl => '$baseUrl/api';
  static String get storageUrl => '$baseUrl/storage';

  // Constants that never change can stay 'const'
  static const String storageTokenKey = 'token';
  static const String storageUserKey = 'user_data';
}
