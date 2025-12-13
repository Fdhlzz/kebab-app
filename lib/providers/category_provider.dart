import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? image;

  CategoryModel({required this.id, required this.name, this.image});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  int _selectedCategoryId = 0;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  int get selectedCategoryId => _selectedCategoryId;

  final ApiService _api = ApiService();

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint("🔍 FETCHING CATEGORIES...");

      final response = await _api.client.get('/categories');

      // ✅ FIX: Check the Data Type before parsing

      // CASE 1: The API returns a direct List [ {...}, {...} ]
      if (response.data is List) {
        debugPrint("📦 Format: Direct List");
        final List data = response.data;
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      // CASE 2: The API returns an Object { "data": [...] }
      else if (response.data is Map && response.data['data'] is List) {
        debugPrint("📦 Format: Wrapped Data Object");
        final List data = response.data['data'];
        _categories = data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        debugPrint("⚠️ Unknown API Format: ${response.data.runtimeType}");
      }

      debugPrint("✅ LOADED ${_categories.length} CATEGORIES");
    } catch (e) {
      debugPrint("❌ ERROR fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
