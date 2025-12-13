import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  final ApiService _api = ApiService();

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ Use debugPrint instead of print
      debugPrint("🚀 FLUTTER: Fetching products...");

      final response = await _api.client.get('/products');

      debugPrint("✅ API RESPONSE: ${response.statusCode}");

      if (response.data['data'] != null) {
        final List data = response.data['data'];
        _products = data.map((json) => Product.fromJson(json)).toList();
        debugPrint("✅ PARSED: ${_products.length} products loaded.");
      } else {
        debugPrint("⚠️ WARNING: 'data' field is null in response");
      }
    } catch (e) {
      debugPrint("❌ ERROR fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
