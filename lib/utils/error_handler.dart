import 'package:dio/dio.dart';

class ErrorHandler {
  static String parse(dynamic error) {
    if (error is DioException) {
      // ✅ FIX: Changed 'order.type' to 'error.type'
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Koneksi waktu habis. Silakan coba lagi.";

        case DioExceptionType.connectionError:
          return "Tidak ada koneksi internet. Cek wifi/data seluler Anda.";

        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);

        case DioExceptionType.cancel:
          return "Permintaan dibatalkan.";

        default:
          return "Terjadi kesalahan jaringan yang tidak diketahui.";
      }
    } else {
      // General Dart Errors
      return "Terjadi kesalahan: $error";
    }
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) return "Terjadi kesalahan pada server.";

    try {
      final data = response.data;

      // 1. Check for Laravel standard 'message' field
      if (data is Map && data['message'] != null) {
        return data['message'];
      }

      // 2. Check for Validation errors
      if (data is Map && data['errors'] != null) {
        Map<String, dynamic> errors = data['errors'];
        if (errors.isNotEmpty) {
          // Flatten array errors to a single string
          var firstError = errors.values.first;
          if (firstError is List) return firstError[0];
          return firstError.toString();
        }
      }

      // 3. Check status codes if no message found
      switch (response.statusCode) {
        case 400:
          return "Permintaan tidak valid.";
        case 401:
          return "Email atau password salah.";
        case 403:
          return "Akses ditolak.";
        case 404:
          return "Data tidak ditemukan.";
        case 422:
          return "Data yang dikirim tidak valid.";
        case 500:
          return "Server sedang bermasalah. Coba lagi nanti.";
        default:
          return "Terjadi kesalahan (${response.statusCode}).";
      }
    } catch (e) {
      return "Gagal memproses respon server.";
    }
  }
}
