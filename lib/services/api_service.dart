import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('userName', data['user']['name']);

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<List<dynamic>> fetchMenu() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.menu),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'];
      } else {
        throw Exception('Failed to load menu');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.orders),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e) {
        // Ignore errors during logout
      }
    }
    await prefs.clear();
  }
}
