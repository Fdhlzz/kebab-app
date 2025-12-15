import 'package:flutter/material.dart';
import '../utils/constants.dart'; // ✅ Needed for AppConstants.storageUrl

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final double totalPrice;
  final double shippingCost;
  final double grandTotal;
  final DateTime date; // ✅ Changed to DateTime for proper formatting
  final String shippingAddress;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalPrice,
    required this.shippingCost,
    required this.grandTotal,
    required this.date,
    required this.items,
    required this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    // 1. Helper to extract numbers safely
    double parseDouble(dynamic val) => double.tryParse(val.toString()) ?? 0.0;

    // 2. Timezone Logic (Force WITA if server sends naked string)
    String rawDate = json['created_at'] ?? DateTime.now().toString();
    if (!rawDate.contains('+') && !rawDate.endsWith('Z')) {
      rawDate = "$rawDate+0800"; // Append WITA offset
    }

    // 3. Calculation
    double subTotal = parseDouble(json['total_price']);
    double shipCost = parseDouble(json['shipping_cost']);

    return Order(
      id: json['id'],
      orderNumber: "ORD-#${json['id']}",
      status: json['status'] ?? 'pending',
      totalPrice: subTotal,
      shippingCost: shipCost,
      grandTotal: subTotal + shipCost,
      date: DateTime.parse(rawDate).toLocal(), // ✅ Convert to device local time
      shippingAddress: json['shipping_address'] ?? 'Alamat tidak tersedia',
      items: itemsList,
    );
  }

  // --- UI Helpers ---

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'on_delivery':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return "Menunggu Konfirmasi";
      case 'processing':
        return "Sedang Disiapkan";
      case 'on_delivery':
        return "Dalam Pengiriman";
      case 'completed':
        return "Selesai";
      case 'cancelled':
        return "Dibatalkan";
      default:
        return status;
    }
  }
}

class OrderItem {
  final int id;
  final String productName;
  final int quantity;
  final double price;
  final String image; // ✅ Non-nullable String (safer for UI)

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // 1. Extract Product Data safely
    var productData = json['product'];

    // 2. ✅ ROBUST IMAGE LOGIC (Matches Product Model)
    String imageUrl = '';

    if (productData != null && productData['images'] != null) {
      var imagesList = productData['images'] as List;
      if (imagesList.isNotEmpty) {
        String rawPath = imagesList[0]['image_path'] ?? '';

        if (rawPath.isNotEmpty) {
          if (rawPath.startsWith('http')) {
            imageUrl = rawPath;
          } else {
            // Fix broken link by prepending base URL
            imageUrl = '${AppConstants.storageUrl}/$rawPath';
          }
        }
      }
    }

    return OrderItem(
      id: json['id'],
      productName: productData != null ? productData['name'] : 'Item Unknown',
      image: imageUrl, // ✅ Will be a full URL or empty string
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}
