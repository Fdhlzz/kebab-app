import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  final ApiService _api = ApiService();

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  // Check if user is already logged in (on app start)
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      _token = prefs.getString('token');
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // Login Function
  Future<void> login(String email, String password) async {
    try {
      // 1. Send data to Laravel
      final response = await _api.client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // 2. Save Token
      if (response.data['token'] != null) {
        _token = response.data['token'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        notifyListeners();
      }
    } catch (e) {
      // Pass error to UI
      throw Exception("Invalid Email or Password");
    }
  }

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

      if (response.data['token'] != null) {
        _token = response.data['token'];
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        notifyListeners();
      }
    } catch (e) {
      // 🔍 DEBUG: Print the real error to Console
      if (e.runtimeType.toString() == 'DioException') {
        final res = (e as dynamic).response;
        debugPrint("❌ REGISTRATION ERROR: ${res?.data}");

        // Try to show the specific validation message from Laravel
        if (res != null && res.data['message'] != null) {
          throw Exception(res.data['message']);
        }
      }
      // Default fallback
      throw Exception(
        "Registration Failed. Please check your internet or inputs.",
      );
    }
  }

  // Logout Function
  Future<void> logout() async {
    try {
      // Optional: Call logout API
      // await _api.client.post('/auth/logout');
    } catch (e) {
      // Ignore API errors on logout
    } finally {
      _token = null;
      _isAuthenticated = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      notifyListeners();
    }
  }
}
