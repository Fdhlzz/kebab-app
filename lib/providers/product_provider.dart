import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  String _searchQuery = "";

  // ✅ Filter based on your model's 'title'
  List<Product> get products {
    if (_searchQuery.isEmpty) {
      return _products;
    }
    return _products
        .where(
          (p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.client.get('/products');
      final List data = response.data['data'] ?? response.data;
      _products = data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
