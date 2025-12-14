import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart'; // Ensure you created this model in the previous step

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
      // Calls GET /api/orders
      final response = await _api.client.get('/orders');

      // Handle Laravel Pagination or Standard Response
      final List data = response.data['data'] ?? [];

      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Fetch Order Error: $e");
      // Keep previous orders or empty list on error
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
              'price':
                  item.product.price, // Sending price for verification/history
            },
          )
          .toList();

      // 2. Send POST Request
      await _api.client.post(
        '/orders',
        data: {
          'address_id': addressId,
          'items': itemsPayload,
          'total_price': subtotal,
          'shipping_cost': shippingCost,
          'payment_method': 'COD', // Defaulting to COD for now
        },
      );

      // 3. Refresh the order list locally so the "Orders" tab is updated immediately
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
