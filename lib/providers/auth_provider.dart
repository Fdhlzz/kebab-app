import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart'; // ✅ Import your constants

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  final ApiService _api = ApiService();

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  User? get user => _user;

  AuthProvider() {
    checkAuth();
  }

  // 1. Check Auth (App Start)
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ USE CONSTANT
    if (prefs.containsKey(AppConstants.storageTokenKey)) {
      _token = prefs.getString(AppConstants.storageTokenKey);
      debugPrint(
        "🔄 AUTO-LOGIN: Token loaded from ${AppConstants.storageTokenKey}",
      );

      // Fetch user profile immediately
      await fetchUser();
    } else {
      debugPrint("⚪ NO TOKEN FOUND: Guest Mode");
    }
    notifyListeners();
  }

  // 2. Fetch User Data
  Future<void> fetchUser() async {
    try {
      final response = await _api.client.get('/user');
      _user = User.fromJson(response.data);
      notifyListeners();
      debugPrint("👤 USER DATA LOADED: ${_user!.name}");
    } catch (e) {
      debugPrint("❌ ERROR LOADING USER: $e");
      if (e.toString().contains("401")) {
        logout();
      }
    }
  }

  // 3. Login
  Future<void> login(String email, String password) async {
    try {
      final response = await _api.client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] ?? response.data['accessToken'];

      if (token != null) {
        _token = token;

        // Save User Data if available in response
        if (response.data['user'] != null) {
          _user = User.fromJson(response.data['user']);
        } else {
          // Otherwise fetch it separately
          fetchUser();
        }

        // ✅ USE CONSTANT
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.storageTokenKey, _token!);

        notifyListeners();
      }
    } catch (e) {
      debugPrint("🔴 LOGIN ERROR: $e");
      throw Exception("Invalid Email or Password");
    }
  }

  // 4. Register
  Future<void> register(String name, String email, String password) async {
    try {
      await _api.client.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
    } catch (e) {
      debugPrint("🔴 REGISTER ERROR: $e");
      rethrow;
    }
  }

  // 5. Logout
  Future<void> logout() async {
    try {
      // Optional: Call logout API to invalidate token on server
      // await _api.client.post('/auth/logout');
    } catch (e) {
      // Ignore network errors during logout
    }

    _token = null;
    _user = null;

    // ✅ USE CONSTANT
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.storageTokenKey);
    // Optional: Also remove user data if you saved it separately
    // await prefs.remove(AppConstants.storageUserKey);

    debugPrint("👋 LOGGED OUT");
    notifyListeners();
  }

  // 6. Update Address
  Future<void> updateAddress(String districtId, String address) async {
    try {
      await _api.client.post(
        '/user/address',
        data: {'district_id': districtId, 'address': address},
      );

      // Update local state instantly
      if (_user != null) {
        _user!.districtId = districtId;
        _user!.address = address;
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Gagal update alamat");
    }
  }
}
