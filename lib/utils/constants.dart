class AppConstants {
  // ---------------------------------------------------------------------------
  // 🔴 IMPORTANT: If you restart Ngrok, this URL will change!
  // Update it here every time you run 'ngrok http 8000'.
  // ---------------------------------------------------------------------------

  // ✅ Ngrok URL (HTTPS is required for Midtrans/Production simulation)
  static const String baseUrl =
      'https://ladawn-unadhering-difficultly.ngrok-free.dev';

  // ---------------------------------------------------------------------------
  // ❌ OLD LOCALHOST CONFIGS (Keep for reference)
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://192.168.1.X:8000'; // Physical Device LAN
  // ---------------------------------------------------------------------------

  // API Endpoints
  static const String apiUrl = '$baseUrl/api';

  // Storage for Images (Product/Avatar)
  static const String storageUrl = '$baseUrl/storage';
  static const String storageTokenKey = 'token';
  static const String storageUserKey = 'user_data';
}
