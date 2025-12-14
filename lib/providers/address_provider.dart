import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;

  AddressModel? get primaryAddress {
    try {
      return _addresses.firstWhere((a) => a.isPrimary);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.client.get('/addresses');
      final List data = response.data['data'];
      _addresses = data.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching addresses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(Map<String, dynamic> data) async {
    await _api.client.post('/addresses', data: data);
    await fetchAddresses();
  }

  Future<void> updateAddress(int id, Map<String, dynamic> data) async {
    try {
      await _api.client.put('/addresses/$id', data: data);
      await fetchAddresses(); // Refresh list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAddress(int id) async {
    await _api.client.delete('/addresses/$id');
    await fetchAddresses();
  }

  Future<void> setPrimary(int id) async {
    await _api.client.post('/addresses/$id/primary');
    await fetchAddresses();
  }
}
