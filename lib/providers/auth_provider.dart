import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  final ApiService _api = ApiService();

  // ✅ LOGIC CHANGE:
  // We don't use a boolean flag anymore.
  // If token exists, you are authenticated. Simple and bug-free.
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  String? get token => _token;

  AuthProvider() {
    // Check auth immediately when Provider is created
    checkAuth();
  }

  // 1. Check Storage on App Start
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      _token = prefs.getString('token');
      debugPrint("🔄 AUTO-LOGIN SUCCESS: Token loaded");
    } else {
      debugPrint("⚪ NO TOKEN FOUND: Guest Mode");
    }
    notifyListeners();
  }

  // 2. Login
  Future<void> login(String email, String password) async {
    try {
      debugPrint("🔵 ATTEMPTING LOGIN: $email");

      final response = await _api.client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      debugPrint("🟢 API RESPONSE: ${response.data}");

      // Check for both 'token' (your fix) and 'accessToken' (default Sanctum)
      final token = response.data['token'] ?? response.data['accessToken'];

      if (token != null) {
        _token = token;

        // Save to Disk
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        debugPrint("✅ LOGIN SUCCESS: Token Saved");
        notifyListeners();
      } else {
        throw Exception(
          "Server returned success but NO TOKEN found in response.",
        );
      }
    } catch (e) {
      debugPrint("🔴 LOGIN ERROR: $e");
      rethrow;
    }
  }

  // 3. Register
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _api.client.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      final token = response.data['token'] ?? response.data['accessToken'];

      if (token != null) {
        _token = token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("🔴 REGISTER ERROR: $e");
      rethrow;
    }
  }

  // 4. Logout
  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    debugPrint("👋 LOGGED OUT");
    notifyListeners();
  }
}
