import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/globals.dart';
import '../screens/connection_screen.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  ApiService() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();

          final savedApiUrl = prefs.getString('api_base_url');
          if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
            options.baseUrl = savedApiUrl;
          }

          final token = prefs.getString(AppConstants.storageTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            debugPrint("⚠️ API Request sent without Token");
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) {
          bool isConnectionError =
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.receiveTimeout ||
              (e.type == DioExceptionType.unknown &&
                  e.message != null &&
                  e.message!.contains('SocketException'));

          if (isConnectionError) {
            debugPrint(
              "🚨 CONNECTION LOST: Redirecting to Connection Screen...",
            );

            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              ConnectionScreen.routeName,
              (route) => false,
            );
            final context = navigatorKey.currentContext;
            if (context != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Koneksi terputus. Silakan konfigurasi ulang IP Server.",
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
            }
          }

          if (e.response?.statusCode == 401) {
            debugPrint("❌ UNAUTHORIZED: Token might be invalid");
          }

          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;

  Future<bool> checkConnection(String ip) async {
    try {
      final tempDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final testUrl = 'http://$ip:8000/api/menu';
      final response = await tempDio.get(testUrl);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Connection Test Failed: $e");
      return false;
    }
  }

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
