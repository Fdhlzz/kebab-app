class AppConstants {
  // =============================================================
  // 🔴 CHANGE THIS IP ADDRESS TO MATCH YOUR PC'S LOCAL IP 🔴
  // Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) to find it.
  static const String ipAddress = '172.16.120.205';
  // =============================================================

  // API Base URL
  static const String baseUrl = 'http://$ipAddress:8000/api';

  // Image Storage URL
  static const String storageUrl = 'http://$ipAddress:8000/storage';

  // Storage Keys
  static const String storageTokenKey = 'token';
  static const String storageUserKey = 'user_data';
}
