import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  List<Order> _orders = [];

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;

  // Filter: Active Orders (Pending, Processing, On Delivery)
  List<Order> get activeOrders => _orders
      .where((o) => ['pending', 'processing', 'on_delivery'].contains(o.status))
      .toList();

  // Filter: History Orders (Completed, Cancelled)
  List<Order> get historyOrders => _orders
      .where((o) => ['completed', 'cancelled'].contains(o.status))
      .toList();

  // --- ACTIONS ---

  /// 1. Fetch User's Orders from Backend
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.client.get('/orders');
      final List data = response.data['data'] ?? [];

      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Fetch Order Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Create a New Order (Checkout)
  Future<bool> createOrder({
    required int addressId,
    required List<CartItem> items,
    required double subtotal,
    required double shippingCost,
    required String paymentMethod, // ✅ NEW: Receive 'COD' or 'QRIS'
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Prepare Items Payload
      List<Map<String, dynamic>> itemsPayload = items
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
              'price': item.product.price,
            },
          )
          .toList();

      // 2. Send POST Request with Payment Method
      await _api.client.post(
        '/orders',
        data: {
          'address_id': addressId,
          'items': itemsPayload,
          'total_price': subtotal,
          'payment_method': paymentMethod, // ✅ UPDATED: Send the selection
        },
      );

      // 3. Refresh list immediately so the UI can grab the new order ID
      await fetchOrders();

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      debugPrint("Create Order Error: $e");
      _isLoading = false;
      notifyListeners();
      return false; // Failed
    }
  }
}
