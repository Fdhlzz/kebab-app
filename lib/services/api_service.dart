import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // Default fallback. This will be overwritten by the interceptor below.
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
    // 1. LOGGER (Helps debug API calls in terminal)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // 2. DYNAMIC URL & AUTH INTERCEPTOR
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();

          // --- [START] DYNAMIC URL LOGIC ---
          // Read the saved API URL from storage (e.g., http://192.168.1.10:8000/api)
          final savedApiUrl = prefs.getString('api_base_url');

          if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
            // Overwrite the Dio baseUrl for this specific request
            options.baseUrl = savedApiUrl;
          }
          // --- [END] DYNAMIC URL LOGIC ---

          // --- [START] AUTH TOKEN LOGIC ---
          final token = prefs.getString(AppConstants.storageTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            debugPrint("⚠️ API Request sent without Token");
          }
          // --- [END] AUTH TOKEN LOGIC ---

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle 401 Unauthorized globally
          if (e.response?.statusCode == 401) {
            debugPrint("❌ UNAUTHORIZED: Token might be invalid or expired");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Expose the client if needed elsewhere
  Dio get client => _dio;

  // ---------------------------------------------------------------------------
  // ✅ CONNECTION TESTER
  // Used by ConnectionScreen to verify IP before saving
  // ---------------------------------------------------------------------------
  Future<bool> checkConnection(String ip) async {
    try {
      // Create a temporary Dio instance just for this test.
      // We use a short timeout so the user doesn't wait long.
      final tempDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      // We try to hit the public 'menu' endpoint.
      // If the server is running, this should return 200 OK.
      final testUrl = 'http://$ip:8000/api/menu';

      final response = await tempDio.get(testUrl);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Connection Test Failed: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // EXISTING METHODS
  // ---------------------------------------------------------------------------

  Future<String?> getQrisUrl() async {
    try {
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
        '/orders/$orderId/payment-proof',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Upload Error: $e");
      return false;
    }
  }
}
