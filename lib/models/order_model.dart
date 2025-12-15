import 'package:flutter/material.dart';

class Order {
  final int id;
  final String orderNumber; // e.g. "ORD-001"
  final String status;
  final double totalPrice;
  final double shippingCost;
  final double grandTotal;
  final String date;
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

    // Helper to extract total (sometimes API sends string, sometimes number)
    double parseDouble(dynamic val) => double.tryParse(val.toString()) ?? 0.0;

    return Order(
      id: json['id'],
      orderNumber: "ORD-#${json['id']}", // Generating a simple ID display
      status: json['status'] ?? 'pending',
      totalPrice: parseDouble(json['total_price']),
      shippingCost: parseDouble(
        json['shipping_cost'],
      ), // Assuming backend sends this
      grandTotal:
          parseDouble(json['total_price']) + parseDouble(json['shipping_cost']),
      date: json['created_at'] ?? '',
      shippingAddress: json['shipping_address'] ?? 'Alamat tidak tersedia',
      items: itemsList,
    );
  }

  // Helper for UI Colors based on status
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

  // Helper for UI Text
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
  final String? image;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      // Handle nested product relation if available
      productName: json['product'] != null
          ? json['product']['name']
          : 'Item Unknown',
      image:
          json['product'] != null &&
              json['product']['images'] != null &&
              (json['product']['images'] as List).isNotEmpty
          ? json['product']['images'][0]['image_path']
          : null,
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}
