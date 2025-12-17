import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  ApiService() {
    // 1. LOGGER
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // 2. AUTH INTERCEPTOR
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.storageTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            debugPrint("⚠️ API Request sent without Token");
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("❌ UNAUTHORIZED: Token might be invalid or expired");
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;

  // ✅ ADD THIS NEW METHOD HERE
  Future<String?> getQrisUrl() async {
    try {
      // Calls: GET /api/settings/qris
      final response = await _dio.get('/settings/qris');

      if (response.statusCode == 200 && response.data['url'] != null) {
        return response.data['url'].toString();
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error fetching QRIS: $e");
      return null;
    }
  }

  Future<bool> uploadPaymentProof(int orderId, String filePath) async {
    try {
      String fileName = filePath.split('/').last;

      FormData formData = FormData.fromMap({
        "payment_proof": await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/orders/$orderId/payment-proof', // Matches Laravel Route
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Upload Error: $e");
      return false;
    }
  }
}
