import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  double _shippingCost = 0.0;

  List<CartItem> get items => _items;
  double get shippingCost => _shippingCost;

  // ✅ Fix: Use product.title for any logic if needed, but here we use price
  double get subTotal =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  double get grandTotal => subTotal + _shippingCost;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void setShippingCost(double cost) {
    _shippingCost = cost;
    notifyListeners();
  }

  void addToCart(Product product) {
    // ✅ Fix: Use product.id
    int index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void decrementItem(int productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // ✅ NEW: Clear Cart (Call on Logout)
  void clearCart() {
    _items.clear();
    _shippingCost = 0.0;
    notifyListeners();
  }
}
