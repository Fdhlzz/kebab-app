import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://localhost:8000/api',
  );

  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get menu => '$baseUrl/menu';
  static String get orders => '$baseUrl/orders';
}
