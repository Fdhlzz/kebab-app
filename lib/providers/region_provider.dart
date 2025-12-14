import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/region_model.dart';

class RegionProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<District> _districts = [];
  bool _isLoading = false;

  List<District> get districts => _districts;
  bool get isLoading => _isLoading;

  Future<void> fetchDistricts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assumes your Laravel API returns { data: [ {id:1, name:'Tamalanrea'}, ... ] }
      final response = await _api.client.get('/districts');
      final List data = response.data['data'] ?? response.data;

      _districts = data.map((json) => District.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ Error fetching districts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
